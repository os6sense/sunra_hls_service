require 'stringio'

require 'sunra_utils/config/hls'
require 'sunra_utils/logging'
require 'sunra_utils/sftp_uploader'

module Sunra
  module HLS
    class Uploader
      include Sunra::Utils::Logging

      attr_reader :uploaded

      attr_accessor :project_id,
                    :booking_id

      # ==== Description
      # Create a new uploader.
      #
      # === Params
      # +config+ :: A config object which supplies details to access the server
      # +destination_presenter+ :: An object which when passed the path and
      # filename returns a string containing the destination directory and
      # filename on the remote server for the m3u8 file and media segments.
      def initialize(config, destination_presenter = nil)
        @dest_pres = destination_presenter
        @sftp = Sunra::Utils::SFTP::Uploader.new(config.hls_server_address,
                                                 config.sftp_username,
                                                 config.hls_base_directory,
                                                 config.sftp_password)
        @uploaded = []
      end

      # ==== Description
      def clear_uploaded
        @uploaded = []
      end

      # ==== Description
      # Upload all the media_segments contained in an m3u8 file to the server.
      # Note that the uploader will keep track of which files have been
      # uploaded and will not upload a file with the same name twice.
      #
      # returns: the list of files just uploaded as an array in the format
      # [[source, destination, media_segment/filename]]
      def upload_ts(pathname, parser)
        parser.load(pathname)
        return_list = []

        segments_for_upload(parser) do | media_segment |
          source = "#{pathname.dirname}/#{media_segment}"
          fail "Sourcefile #{media_segment} not found" unless File.exist?(source)
          @sftp.upload(source, destination(pathname.dirname, media_segment))
          @uploaded << media_segment.path

          return_list << [source,
                          destination(pathname.dirname, media_segment),
                          media_segment]
        end
        return_list
      end

      # ==== Description
      # upload the m3u8 file. Note that it is the *parsed* file which is
      # uploaded which allows us to generate a sliding window for live streams.
      def upload_m3u8(pathname, parser, sliding = false)
        parser.load(pathname)

        logger.info "Uploading M3U8 #{pathname}"

        return @sftp.upload(source,
                            destination(pathname.dirname,
                                        pathname.basename)) unless sliding
        parser.slide!(uploaded: @uploaded)
        parser.write_io_stream(stream = StringIO.new)
        stream.rewind # not technically neccessary but it is neccessary to
                      # rewind if we carry out any operations on the stream

        @sftp.upload_io(stream,
                        destination(pathname.dirname, pathname.basename))
      end

      # ==== Description
      # returns the path and filename to which the file should be uploaded.
      def destination(pathname, file)
        return @dest_pres.destination(pathname.dirname, file) if @dest_pres
        file.to_s
      end

      private

      def segments_for_upload(parser)
        parser.files
          .select { | p | ! @uploaded.include?(p.path) }.each do | file |
          yield file
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require_relative 'm3u8_parser'
  require 'pathname'

  config = Sunra::Config::HLS
  uploader = HLSUploader.new(config)

  m3u8_parser = M3U8Parser.new("/mnt/RAID/VIDEO/NEWSessions/5c145566a7bfe0c4637c9e9f02ccefcd3551d821e48327802474308ada9ca96f9ea47994/53/hls/2014-08-17-205153.M3U8")
  m3u8_file = Pathname.new("/mnt/RAID/VIDEO/NEWSessions/5c145566a7bfe0c4637c9e9f02ccefcd3551d821e48327802474308ada9ca96f9ea47994/53/hls/2014-08-17-205153.M3U8")

  uploader.upload_m3u8(m3u8_file, m3u8_parser, true)
end
