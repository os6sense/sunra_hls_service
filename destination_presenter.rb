# A destination presenter is used to return a custom destination for the file
# based on the path and filename.
class DestinationPresenter
  def destination(path, filename)
    "destination_presenter/#{filename}"
  end
end

# In the case of SunraArchive we want the destination to be based on the
# project and booking ids rather than the path
class SunraArchiveDestinationPresenter
  attr_accessor :project_id,
                :booking_id

  def destination(path, filename)
    "#{@project_id}/#{@booking_id}/#{filename}"
  end

  # Need these for notifiying the recieving end?
  def set_ids(monitor)
    @project_id = monitor.project_id if monitor.respond_to?(:project_id)
    @booking_id = monitor.booking_id if monitor.respond_to?(:booking_id)
  end
end


