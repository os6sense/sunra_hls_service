require_relative 'delivery_service_proxy'

# ==== Description
# The methods of the event handler are called when the m3u8_monitor
# performs an operation such as uploading a file or starting/stopping
# monitoring. This allows us to notify the delivery service that a new
# webcast is beggining or ending, or that a new segment is available
# for a webcast in progress.
class M3U8EventHandler
  def create_delivery_service_proxy(class_name)
    DeliveryServiceProxy.new(
      DeliveryServiceProxy.create_client(HLS.hls_delivery_server_api_key,
                                         HLS.hls_delivery_server_rest_url))
  end

  def initialize
    @delivery_service_proxy = create_delivery_service_proxy('')
  end

  def started

  end

  def stopped

  end

  def files_uploaded(m3u8_parser, uploaded)

  end

  def set_ids(monitor)
    @project_id = monitor.project_id if monitor.respond_to?(:project_id)
    @booking_id = monitor.booking_id if monitor.respond_to?(:booking_id)
  end
end
