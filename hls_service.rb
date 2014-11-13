#!/usr/bin/env ruby

# ==== File hls_service
#
# ==== Description
# Service wrapper for the monitor. Watches the RecordingService for when a
# recording starts. When it does, if there is a HLS file it is then monitored
# for changes. When a change is detected the media segments and a new slinding
# M3U8 file is uploaded to the server.

require 'sunra_utils/config/hls'
require 'sunra_utils/service'

require_relative 'hls_uploader'
require_relative 'destination_presenter'
require_relative 'm3u8_monitor'
require_relative 'm3u8_event_handler'
require_relative 'recording_service_monitor'

include Sunra::Utils::Service
include Sunra::Utils::Config
include Sunra::HLS

class HLSService
  attr_accessor :destination_presenter,
                :rs_monitor,
                :event_handler

  def initialize
    @destination_presenter = create_presenter(HLS.presenter_class)
    @rs_monitor = create_recording_service_monitor(HLS.monitor_class)
    @event_handler = M3U8EventHandler.new(HLS)
  end

  # Create a new M3U8Monitor, which does the heavy lifting of responding to
  # changes in the recording service, creating a file monitor to watch the
  # m3u8 file for changes, and then calling the uploader to upload files
  # based on those changes.
  def create_monitor
    M3U8Monitor.new(HLS, rs_monitor, event_handler) do | m3u8 |
      set_ids
      event_handler.started if event_handler
      m3u8.upload_m3u8 = HLS.upload_m3u8_file
      m3u8.monitor_m3u8_file(@rs_monitor.m3u8,
                             Uploader.new(HLS, @destination_presenter))
    end
  end

  private

  # ==== Description
  # Dynamic presenter to allow for easy changes to logic for where the uploads
  # should be located.
  def create_presenter(class_name)
    Object.const_get(class_name).new
  end

  # ==== Description
  # Dynamic monitor to allow for easy changes to the 'trigger' for when a
  # m3u8 file should be monitored.
  def create_recording_service_monitor(class_name)
    Object.const_get(class_name).new(HLS.recording_server_api_key,
                                     HLS.recording_server_rest_url)
  end

  # ==== Description
  # helper, project and booking id (if needed) are OBTAINED from the rs_monitor
  def set_ids
    @destination_presenter.set_ids(@rs_monitor)
    @event_handler.set_ids(@rs_monitor)
  end

end

service_name = 'hls_service.rb'
usage service_name if ARGV.length != 1

hls_service = HLSService.new
run(hls_service.create_monitor, ARGV[0], service_name)
