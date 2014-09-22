# 'abstract' base class, mainly used to make it easy to adapt the HLS service
# by documenting the required methods
#
class Monitor
  # The Start method of a monitor should be called to begin any process that
  # should be true before any attempt is made to monitor the M3U8 File. If all
  # you want to do is monitor an M3U8 file just use the M3U8 monitor directly
  # and yield within start
  def start(&block)
    fail "Monitor#start not implemented"
    # e.g.  yield
  end

  # use for cleanup
  def stop
    fail "Monitor#stop not implemented"
    # e.g. true
  end

  # return the pathname of the M3U8 File to monitor
  def m3u8
    fail "Monitor#m3u8 not implemented"
    # e.g. Pathname("/tmp/current.m3u8")
  end

  # return true while the m3u8 should be uploaded, false at other
  # times.
  def is_recording?
    fail "Monitor#is_recording? not implemented"
  end
end
