require 'sunra_utils/rest_client'

require 'pathname'

# Access the recording service and provide convienience methods to:
# 1) return the recording status of the service vie is_recording?
# 2) return a Pathname for the M3U8 file via a call to m3u8
module Sunra
  module HLS

    # ==== Description
    # simple cache class to avoid hitting the recording service for multiple
    # calls
    class Cache
      attr_accessor :timeout

      def initialize(timeout = 5)
        @timeout = timeout
        @_data = nil
      end

      def stale?
        return true if @_data.nil? || timeout_expired
        false
      end

      def data
        @_data
      end

      def data=(val)
        @_data = val
        @_last_updated = Time.now
      end

      def timeout_expired
        return true if Time.now > @_last_updated + @timeout
        false
      end
    end

    # ==== Description
    # Provides a simple
    class RecordingService
      # ==== Params
      # +rest_client+ :: A client which respinds to get messages to return
      # json responses from the recording server.
      def initialize(rest_client)
        @rest_client = rest_client
        @cache = Sunra::HLS::Cache.new
      end

      # ==== Description
      # create client provides a prespecified generator for a new rest client
      # and is provided mainly for convienience. It can be used to create a
      # new Recording Service e.g.
      #
      # Example:
      #
      # rc = Sunra::HLS::RecordingService.create_client('rRTzQQPqCyazDmNnTxrC',
      #                       'http://localhost/recording_service/status/')
      # rs = Sunra::HLS::RecordingService.new(rc)
      #
      # ==== Params
      # +api_key+ :: key to access the recording api
      # +resource_url+ :: full url of the recording service STATUS page
      def self.create_client(api_key, resource_url)
        Sunra::Utils::RestClient.new(resource_url, api_key, 'api_key')
      end

      # return true if the recording service ... is recording, false otherwise.
      def is_recording?
        status = get['is_recording']
        return false if status.nil?
        status
      end

      # Return the full path and file_name to the m3u8 file if present if there
      # is no M3U8 entry, nil will be returned
      def m3u8(ignore_recording_status = false)
        return nil if (m3u8 = m3u8_array(ignore_recording_status)).nil?
        return Pathname.new("#{m3u8['directory']}/#{m3u8['filename']}")
      end

      def project_id
        get['project_id']
      end

      def booking_id
        get['booking_id']
      end

      private

      # ==== Params
      # +ignore_recording_status+ :: passing true as a parameter allows for the
      # m3u8 array to be returned *even if the service is not recording*. The
      # utility of this is that if the service is stopped but a recording has
      # been performed, without setting this to true nil will be returned.
      def m3u8_array(ignore_recording_status = false)
        return nil if (recorders = get['recorders']).nil?

        m3u8 = recorders.select { | r | r['format'] == 'M3U8' }

        return nil if m3u8.empty?
        return nil if m3u8[0]['is_recording'] == false &&
                      ignore_recording_status == false
        m3u8[0]
      end

      # ==== Description
      # Returns the JSON result obtained from the rest_client. A simple cache
      # mechanism prevents hitting the server repeatedly if multiple rapid
      # calls are made
      def get
        @cache.data = JSON.parse(@rest_client.get('')) if @cache.stale?
        return @cache.data
      end
    end
  end
end

# Live example
if $PROGRAM_NAME == __FILE__
  # NB:
  rc = Sunra::HLS::RecordingService.create_client('rRTzQQPqCyazDmNnTxrC',
                            'http://localhost/recording_service/status/')
  rs = Sunra::HLS::RecordingService.new(rc)
  puts rs.is_recording?
  puts rs.m3u8
  puts rs.m3u8(true)
  puts rs.project_id
  puts rs.booking_id
end
