require_relative '../../lib/sftp_uploader'

class HLSUploader
  attr_reader :uploaded

  attr_accessor :project_id,
                :booking_id

  def initialize(config)
    @sftp = SFTPUploader.new(config.hls_server_address,
                             config.sftp_username,
                             config.hls_base_directory,
                             config.sftp_password)
    @uploaded = []
  end

  def upload_ts(pathname, parser)
    parser.load(pathname)

    (parser.files - @uploaded).each do | file |
      source = "#{pathname.dirname}/#{file}"
      destination = file
      puts "UPLOADING *** #{file}"
      @uploaded << file
    end
  end

  def upload_m3u8(pathname, parser, sliding = false)
    puts "uploading_m3u8 #{pathname}"
  end
end

if $PROGRAM_NAME == __FILE__
  require_relative 'm3u8_parser'
  require 'pathname'

  uploader = HLSUploader.new
  m3u8_parser = M3U8Parser.new
  m3u8_file = Pathname.new("/mnt/RAID/VIDEO/NEWSessions/5c145566a7bfe0c4637c9e9f02ccefcd3551d821e48327802474308ada9ca96f9ea47994/53/hls/2014-08-17-205153.M3U8")

  uploader.upload_ts(m3u8_file, m3u8_parser)
  puts "******** should be zero"
  uploader.upload_ts(m3u8_file, m3u8_parser)
end
