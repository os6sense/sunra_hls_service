require_relative 'delivery_service_proxy'

# ==== Description
# The methods of the event handler are called when the m3u8_monitor
# performs an operation such as uploading a file or starting/stopping
# monitoring. This allows us to notify the delivery service that a new
# webcast is beggining or ending, or that a new segment is available
# for a webcast in progress.
class M3U8EventHandler
  attr_reader :webcast_id

  def self.create_delivery_service_proxy(config)
    DeliveryServiceProxy.new(
      DeliveryServiceProxy.create_client(config.hls_delivery_server_api_key,
                                         config.hls_delivery_server_rest_url))
  end

  def initialize
    @dsp = self.class.create_delivery_service_proxy('')
    @project_id, @booking_id, @webcast_id = nil, nil, nil
  end

  def started
    @session_id = @dsp.notify_session_start(@webcast_id)['id']
  end

  def stopped
    @dsp.notify_session_end(@webcast_id, @session_id)
  end

  def files_uploaded(m3u8_parser, uploaded)
    @dsp.notify_hls_file(@webcast_id, @session_id, uploaded)
  end

  def set_ids(monitor)
    return unless monitor.respond_to?(:project_id) && monitor.respond_to?(:booking_id)
    @project_id, @booking_id = monitor.project_id, monitor.booking_id

    # The webcast PROJECT should have been (manually) created by this point
    # hence we should be able to obtain a webcast id.
    if @project_id && @booking_id
      @webcast_id = DeliveryServiceProxy.webcast_id(@project_id, @booking_id)
    end
  end
end
