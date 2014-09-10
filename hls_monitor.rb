require_relative 'file_monitor'
require_relative 'recording_service_monitor'
require_relative 'hls_uploader'
require_relative 'm3u8_parser'

require 'sunra_config/hls'
require 'sunra_logging'

# Combines everything

class HLSmonitor
  # Maximum number of seconds to wait before beggining to monitor the M3U8
  # file for changes. Useful if the file is not written until the first ts
  # file has been generated.
  attr_accessor :max_delay

  def initialize(config)
    @config = config
    @rsm = RecordingServiceMonitor.new(config.recording_server_api_key,
                                       config.recording_server_rest_url)
    @max_delay = 100
  end

  def start
    @_stopped = false
    @rsm.start do
      @uploader = HLSUploader.new(@config)
      @uploader.project_id = @rsm.project_id
      @uploader.booking_id = @rsm.booking_id

      m3u8_pathname = @rsm.m3u8 # its possible when the recording stops for
                                # the result of a call to m3u8 to return nil
      #
      monitor_file(m3u8_pathname, @uploader)
    end
    start unless @stopped
  end

  def stop
    @_stopped = true
    @rsm.stop
  end

  private

  def monitor_file(m3u8_pathname, uploader)
    delay_start(m3u8_pathname) # allow time for the m3u8 to be written.

    m3u8_parser = M3U8Parser.new

    FileMonitor.add_watch(m3u8_pathname) do
      uploader.upload_ts(m3u8_pathname, m3u8_parser)
      uploader.upload_m3u8(m3u8_pathname, m3u8_parser, true)

      if m3u8_parser.finished? || @rsm.is_recording? == false
        puts "stopping FileMonitor"
        puts "m3u8_parser.finished? = #{m3u8_parser.finished?}"
        puts "@rsm.is_recording? = #{ @rsm.is_recording?}"
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
      SunraLogging::logger.debug("hls_monitor") { "delay_start #{delay}" }
      sleep 1
      continue if (delay += 1) >= @max_delay
    end
  end
end

if $PROGRAM_NAME == __FILE__
  monitor = HLSmonitor.new(Sunra::Config::HLS)
  monitor.start
end
