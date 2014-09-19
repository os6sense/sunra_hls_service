require "sunra_logging"
require_relative '../../lib/sftp_uploader'

class HLSUploader
  include SunraLogging

  attr_reader :uploaded

  attr_accessor :project_id,
                :booking_id

  # Create a new uploader.
  #
  # === Params
  # +config+ :: A config object which supplies details to access the server
  # +destination_presenter+ :: An object which when passed the path and
  # filename returns a string containing the destination directory and filename
  # on the remote server.
  def initialize(config, destination_presenter = nil)
    @dest_pres = destination_presenter
    @sftp = SFTPUploader.new(config.hls_server_address,
                             config.sftp_username,
                             config.hls_base_directory,
                             config.sftp_password)
    @uploaded = []
  end

  def clear_uploaded
    @uploaded = []
  end

  # Upload all the media_segments contained in an m3u8 file to the server.
  # Note that the uploader will keep track of which files have been uploaded
  # and will not upload a file with the same name twice.
  #
  # This may be a problem ... clear uploads?
  def upload_ts(pathname, parser)
    parser.load(pathname)

    (parser.files - @uploaded).each do | file |
      source = "#{pathname.dirname}/#{file}"
      fail "Sourcefile #{file} not found" unless File.exist?(source)
      @sftp.upload(source, destination(pathname.dirname, file))
      @uploaded << file
    end
  end

  # upload the m3u8 file. Note that it is the *parsed* file which is uploaded
  # which allows us to generate a sliding window for live streams.
  def upload_m3u8(pathname, parser, sliding = false)
    parser.load(pathname)
    @sftp.upload(source, destination(pathname.dirname, pathname.basename))
    logger.info "uploading_m3u8 #{pathname}"
  end

  def destination(pathname, file)
    return @dest_pres.destination(pathname.dirname, file) if @dest_pres
    file.to_s
  end

  private

  # From the source m3u8 file we need to generate a sliding window
  # m3u8 file that tracks the number of files removed and has the
  # correct duration to match the spec
  def upload_sliding_m3u8(pathname, parser, sliding = false)
    parser.load(pathname)
    parser.slide!(@uploaded)

    @sftp.upload_io(parser, destination(pathname.dirname, pathname.basename))
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
