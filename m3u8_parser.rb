require 'm3uzi'

# Very lazy and ineffficient reloading and reading of the M3U8 file
# via a wrapper around M3Uzi.
class M3U8Parser
  def initialize
  end

  def load(path_and_filename)
    @parser = M3Uzi.read(path_and_filename)
  end

  def files
    @parser.filenames
  end

  def tags
    @parser.tags
  end

  def finished?

    @parser.final_media_file
  end


end

if $PROGRAM_NAME == __FILE__
  parser = M3U8Parser.new
  parser.load("/mnt/RAID/VIDEO/NEWSessions/da5d3b742663d7dbbfceac16d0f15fdfbf561eb22e5192faf07268ccc89bd53d70489a7a/55/hls/2014-08-18-095925.M3U8")
  puts parser.files
  puts parser.tags
  puts parser.finished?
end
