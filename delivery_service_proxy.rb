require 'sunra_utils/rest_client'
require 'sunra_utils/config/hls'
require 'sunra_utils/logging'

module Sunra
  module HLS
    class DeliveryServiceProxy
      attr_reader :webcast_id,
                  :session_id

      # ==== Description
      # Create a new instance of the proxy. An instance of
      # Sunra::Utils::RestClient is required as a parameter.
      def initialize(rest_client)
        @rest_client = rest_client
      end

      # ==== Description
      # Creates and returns a sunra utils rest client using the URL and api key
      # provided.
      def self.create_client(resource_url, api_key)
        Sunra::Utils::RestClient.new(resource_url, api_key, 'api_key')
      end

      # ==== Description
      # Obtain a webcast id if we know the project and booking_id
      def webcast_id(project_id, booking_id)
        result = JSON.parse(@rest_client
          .get('lookup.json', {project_id: project_id, booking_id: booking_id}))

        # a booking should only ever have a single webcast id associated
        result.empty? ? nil : result[0]['id'] # : result.map { | wc | wc['id'] }
      end

      # ==== Description
      # TODO: Create a new webcast PROJECT - this is likely to be used
      # by the project manager hence this proxy should probably move to
      # sunra_utils - sunra_utils/proxys?
      def create_webcast(webcast_details_hash)
        @webcast_id = 1
        # check if already exists
        return @webcast_id
      end

      # ==== Description
      # Notify the delivery server that a webcast has started and to expect
      # hls_files.
      #
      # Returns: The session_id returned from creating the session
      def notify_session_start(webcast_id)
        url = "#{webcast_id}/sessions.json"
        @session_id = JSON.parse(@rest_client.create(url, {}))['id']
      end

      # ==== Description
      # Notify the delivery server that a webcast has ended.
      def notify_session_end(webcast_id, session_id)
        url = "#{webcast_id}/sessions/#{session_id}.json"
        JSON.parse @rest_client.update(url , {})
      end

      # ==== Description
      # Notify the delivery server that a new hls file has been uploaded.
      def notify_hls_file(webcast_id, session_id, file)
        directory, media_segment, _source = *file

        data = { session_id: session_id,
                 filename: media_segment.to_s ,
                 directory: directory,
                 filesize: '10000',
                 duration: media_segment.duration,
                 format: 'ts' }

        url = "#{webcast_id}/sessions/#{session_id}/hls_files.json"
        JSON.parse @rest_client.create(url, data)
      end

      # ==== Description
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

  # webcast create
  # session_id = dsp.notify_session_start(2)#['id']
  #
  # webcast end
#  dsp.notify_session_end(2, session_id)

  #fake_file = ['/somewhere/project_id_here/booking_id_here/',
  #             '123-12.ts',
  #             'source - needs to be a real file']

  # file upload
  #dsp.notify_hls_file(2, 53, fake_file)
  #
  # get id of webcast provided we have the project id & booking id
  puts DeliveryServiceProxy.webcast_id('id123', '12')




end
