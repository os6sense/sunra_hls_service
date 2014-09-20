# A destination presenter is used to return a custom destination for the file
# based on the path and filename.
class DestinationPresenter
  # ==== Description
  # ==== Params
  # +path+ :: path, relative to the m3u8 file
  # +filename+ :: name of the file
  def destination(path, filename)
    fail 'filename must not be nil' unless filename
    fail 'path must not be nil' unless path
    "#{path}/#{filename}"
  end
end

# ==== Description
# In the case of SunraArchive we want the destination to be based on the
# project and booking ids rather than the path
class SunraArchiveDestinationPresenter < DestinationPresenter
  attr_accessor :project_id,
                :booking_id

  def destination(_path, filename)
    super('', filename)
    fail 'project_id and booking_id must be set' unless @project_id && \
      @booking_id
    "#{@project_id}/#{@booking_id}/#{filename}"
  end

  # Need these for notifiying the recieving end?
  def set_ids(monitor)
    @project_id = monitor.project_id if monitor.respond_to?(:project_id)
    @booking_id = monitor.booking_id if monitor.respond_to?(:booking_id)
  end
end
