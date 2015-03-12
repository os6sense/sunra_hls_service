require_relative 'file_monitor'
require_relative 'm3u8_parser'

require 'sunra_utils/config/hls'
require 'sunra_utils/logging'

include Sunra::Utils

module Sunra
  module HLS
    # ==== Description
    # monitors an m3u8 file for changes and performs actions when changed.
    class M3U8Monitor
      include Sunra::Utils::Logging

      # Maximum number of seconds to wait before beggining to monitor the M3U8
      # file for changes. Useful if the file is not written until the first ts
      # file has been generated.
      attr_accessor :max_delay,
                    :upload_m3u8,
                    :event_handler

      attr_reader :uploader

      # ==== Description
      # Note that the block is passed in the initializer since the monitor
      # is run as a service hence the block cannot be directly passed to
      # +start+
      def initialize(config, monitor, event_handler, &block)
        @config, @monitor, @event_handler = config, monitor, event_handler
        @block = block
        set_defaults
      end

      # ==== Description
      def start(_ignore=false)
        @_stopped = false
        @monitor.start { @block.call(self) }
        start unless @_stopped # loop
      end

      # ==== Description
      def stop
        @_stopped = true
        @monitor.stop
      end

      # ==== Description
      def monitor_m3u8_file(m3u8_pathname, uploader)
        return nil unless m3u8_file_exists?(m3u8_pathname)

        @uploader = uploader
        delay_start(m3u8_pathname) # allow time for the m3u8 to be written.
        add_file_monitor_watch(m3u8_pathname, M3U8Parser.new(m3u8_pathname))
      end

      private

      # ==== Description
      # The block within add_watch will be called whenever the file pointed
      # to by m3u8_pathname changes in anyway.
      def add_file_monitor_watch(m3u8_pathname, m3u8_parser)

        FileMonitor.add_watch(m3u8_pathname) do

          perform_uploads(m3u8_pathname, m3u8_parser)

          if m3u8_parser.finished? || @monitor.is_recording? == false
            logger.info 'Stopping FileMonitor.'
            logger.debug "(parser: #{m3u8_parser.finished?}, "\
                         "monitor: #{ @monitor.is_recording? })"
            FileMonitor.stop
            @event_handler.stopped if @event_handler
          end
        end

        FileMonitor.run
      end

      # ==== Description
      # Do the actually work of calling the uploader to upload the ts and (if
      # set) the m3u8 file
      def perform_uploads(m3u8_pathname, m3u8_parser)
        uploaded = @uploader.upload_ts(m3u8_pathname, m3u8_parser)
        return unless uploaded.size > 0
        @uploader.upload_m3u8(m3u8_pathname, m3u8_parser, true) if @upload_m3u8
        @event_handler.files_uploaded(m3u8_parser, uploaded) if @event_handler
      end

      # ==== Description
      # return nil unless the m3u8 file exists
      def m3u8_file_exists?(m3u8_pathname)
        if m3u8_pathname.nil?
          logger.error 'm3u8_pathname is nil in call to monitor_m3u8_file.'
          logger.debug 'pathname: #{#m3u8_pathname}'
          return false
        end
        true
      end

      # ==== Description
      def set_defaults
        @max_delay, @upload_m3u8, @uploader = 100, true, nil
      end

      # ==== Description
      # The M3U8 file may not be written until the first ts file has been
      # created.  delay start waits until the file exists before returning.
      # +max_delay+ can be set to constrain this.
      def delay_start(pathname)
        delay = 0
        until File.exists?(pathname)
          logger.debug("hls_monitor") { "delay_start #{delay}" }
          sleep 1
          continue if (delay += 1) >= @max_delay
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  config = Sunra::Utils::Config::HLS
  rsm = RecordingServiceMonitor.new(config.recording_server_api_key,
                                    config.recording_server_rest_url)
  monitor = M3U8Monitor.new(config, rsm)
  monitor.start
end
