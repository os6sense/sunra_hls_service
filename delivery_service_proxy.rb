require 'sunra_utils/rest_client'
require 'sunra_utils/config/hls'
require 'sunra_utils/logging'

module Sunra
  module HLS
    class DeliveryServiceProxy
      attr_reader :webcast_id,
                  :session_id

      def initialize(rest_client)
        @rest_client = rest_client
      end

      def self.create_client(resource_url, api_key)
        Sunra::Utils::RestClient.new(resource_url, api_key, 'api_key')
      end

      # Create a new webcast project
      def create_webcast(webcast_details_hash)
        @webcast_id = 1
        return @webcast_id
      end

      # Notify the delivery server that a webcast has started and to expect
      # hls_files.
      #
      # Returns: The session_id returned from creating the session
      def notify_session_start(webcast_id)
        url = "#{webcast_id}/sessions.json"
        @session_id = JSON.parse @rest_client.create(url, {})
      end

      # Notify the delivery server that a webcast has ended.
      def notify_session_end(webcast_id, session_id)
        url = "#{webcast_id}/sessions/#{session_id}.json"
        JSON.parse @rest_client.update(url , {})
      end

      # Notify the delivery server that a new hls file has been uploaded.
      def notify_hls_file(webcast_id, session_id, file)
        directory = file[0]
        media_segment = file[1]
        data = { session_id: session_id,
                 filename: media_segment.to_s ,
                 directory: directory,
                 filesize: '10000',
                 duration: '10',# media_segment.duration,
                 format: 'ts' }

        url = "#{webcast_id}/sessions/#{session_id}/hls_files.json"
        JSON.parse @rest_client.create(url, data)
      end

      # Helper method - add a batch of hls files.
      def notify_hls_files(webcast_id, session_id, files)
        files.each { | file | notify_hls_file(session_id, file) }
      end

    end
  end
end

if $PROGRAM_NAME == __FILE__
  dsp_client = Sunra::HLS::DeliveryServiceProxy.create_client(
                            'http://localhost:3000/webcasts/',
                            'rRTzQQPqCyazDmNnTxrC')
  dsp = Sunra::HLS::DeliveryServiceProxy.new(dsp_client)

  # session_id = dsp.notify_session_start(2)['id']
#  dsp.notify_session_end(2, session_id)

  fake_file = ['/somewhere/project_id_here/booking_id_here/',
               '123-12.ts']

  dsp.notify_hls_file(2, 53, fake_file)
end
