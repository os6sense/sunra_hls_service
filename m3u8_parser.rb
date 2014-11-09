require 'm3uzi2'

# Read and reload the the M3U8 file # via a wrapper around M3Uzi2.
class M3U8Parser
  extend Forwardable

  def_delegators :@parser, :slide!,
                           :to_s,
                           :write_io_stream

  def initialize(path_and_filename = nil)
    self.load(path_and_filename) unless path_and_filename.nil?
  end

  def load(path_and_filename)
    @parser = M3Uzi2::M3Uzi2.new(path_and_filename)
    @parser.read_method = :flock

    # Sometimes the m3u8 file will be being written to just as we attempt to
    # read it, flocking doesnt always solve this and M3Uzi2 is likely to fail
    # when reading it hence we retry.
    begin
      @parser.load
    rescue
      sleep 0.1
      retry if _r = (_r || 0) + 1 and _r <= 3
      raise
    end
  end

  def files
    @parser.media_segments
  end

  def finished?
    @parser.final_media_segment?
  end
end

if $PROGRAM_NAME == __FILE__
  parser = M3U8Parser.new("/mnt/RAID/VIDEO/NEWSessions/da5d3b742663d7dbbfceac16d0f15fdfbf561eb22e5192faf07268ccc89bd53d70489a7a/55/hls/2014-08-18-095925.M3U8")
  puts parser.files
  parser.files.each do | file |
    puts file.to_s
  end

  puts parser.finished?
  #puts parser.to_s
end
