require_relative 'recording_service'
require 'forwardable'

class RecordingServiceMonitor
  extend Forwardable

  def_delegators :@rs, :m3u8,
                       :project_id,
                       :booking_id,
                       :is_recording?

  def initialize(api_key, resource_url)
    rc = Sunra::HLS::RecordingService.create_client(api_key,
                                         resource_url)
    @rs = Sunra::HLS::RecordingService.new(rc)
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

