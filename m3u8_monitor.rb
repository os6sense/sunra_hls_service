require_relative 'file_monitor'
require_relative 'recording_service_monitor'
require_relative 'hls_uploader'
require_relative 'm3u8_parser'
require_relative 'destination_presenter'

require 'sunra_config/hls'
require 'sunra_logging'

class M3U8Monitor
  include SunraLogging

  # Maximum number of seconds to wait before beggining to monitor the M3U8
  # file for changes. Useful if the file is not written until the first ts
  # file has been generated.
  attr_accessor :max_delay

  def initialize(config, monitor)
    @config = config
    @monitor = monitor

    @max_delay = 100
  end

  def start
    @_stopped = false

    @monitor.start do
      # TODO - this block should be yielded to allow for a custom destination
      # presenter to be injected
      dest_pres = SunraArchiveDestinationPresenter.new
      dest_pres.set_ids(@monitor)

      @uploader = HLSUploader.new(@config, dest_pres)

      m3u8_pathname = @monitor.m3u8 # its possible when the recording stops for
                                    # the result of a call to m3u8 to be nil
      monitor_m3u8_file(m3u8_pathname, @uploader)
    end

    start unless @_stopped # loop
  end

  def stop
    @_stopped = true
    @monitor.stop
  end

  private

  def monitor_m3u8_file(m3u8_pathname, uploader)
    delay_start(m3u8_pathname) # allow time for the m3u8 to be written.

    m3u8_parser = M3U8Parser.new

    FileMonitor.add_watch(m3u8_pathname) do
      uploader.upload_ts(m3u8_pathname, m3u8_parser)
      uploader.upload_m3u8(m3u8_pathname, m3u8_parser, true)

      if m3u8_parser.finished? || @monitor.is_recording? == false
        logger.info "Stopping FileMonitor (p: #{m3u8_parser.finished?}, "\
                    "m: #{ @monitor.is_recording? })"
        FileMonitor.stop
      end
    end

    FileMonitor.run
  end

  # The M3U8 file may not be written until the first ts file has been created.
  # delay start waits until the file exists before returning. +max_delay+ can
  # be set to constrain this.
  def delay_start(pathname)
    delay = 0
    until File.exists?(pathname)
      logger.debug("hls_monitor") { "delay_start #{delay}" }
      sleep 1
      continue if (delay += 1) >= @max_delay
    end
  end
end

if $PROGRAM_NAME == __FILE__
  config = Sunra::Config::HLS

  puts config.recording_server_api_key
  rsm = RecordingServiceMonitor.new(config.recording_server_api_key,
                                    config.recording_server_rest_url)
  monitor = M3U8Monitor.new(config, rsm)
  monitor.start
end
