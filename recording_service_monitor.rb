require 'forwardable'

require_relative 'monitor'
require_relative 'recording_service_proxy'

# A Thread that watches the recording_service for changes in status (start/stop)
# and yields to the block passed to the start method when a recording starts
class RecordingServiceMonitor < Monitor
  extend Forwardable

  def_delegators :@rs, :m3u8,
                       :project_id,
                       :booking_id,
                       :is_recording?

  def initialize(api_key, resource_url)
    rc = Sunra::HLS::RecordingServiceProxy.create_client(api_key,
                                         resource_url)
    @rs = Sunra::HLS::RecordingServiceProxy.new(rc)
  end

  def start(&block)
    @rs_thread = Thread.new do
      while check_status == false
        sleep 1
      end
      yield
    end
    @rs_thread.join
  end

  def stop
    @rs_thread.exit
  end

  private

  def check_status
    @rs.is_recording? && @rs.m3u8 != nil
  end
end

