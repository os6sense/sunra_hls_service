#!/usr/bin/env ruby

# ==== File hls_service
#
# ==== Description
# Service wrapper for the monitor. Watches the RecordingService for when
# a recording starts. When it does, if there is a HLS file the file is then
# monitored for changes. When a change is detected the media segments and a new
# slinding M3U8 file is uplaoded to the server.

require 'sunra_utils/config/hls'
require 'sunra_utils/service'

require_relative 'hls_uploader'
require_relative 'destination_presenter'
require_relative 'm3u8_monitor'
require_relative 'recording_service_monitor'

include Sunra::Utils::Service
include Sunra::Utils::Config
include Sunra::HLS

service_name = 'hls_service.rb'
usage service_name if ARGV.length != 1

# Dynamic presenter to allow for easy changes to logic for where the uploads
# should be located.
def create_presenter(class_name)
  Object.const_get(class_name).new
end

# Dynamic monitor to allow for easy changes to the 'trigger' for when a
# m3u8 file should be monitored.
def create_recording_service_monitor(class_name)
  Object.const_get(class_name).new(HLS.recording_server_api_key,
                                   HLS.recording_server_rest_url)
end

destination_presenter = create_presenter(HLS.presenter_class)
rs_monitor = create_recording_service_monitor(HLS.monitor_class)

m3u8_monitor = M3U8Monitor.new(HLS, rs_monitor) do | m3u8 |
  destination_presenter.set_ids(rs_monitor)
  m3u8.monitor_m3u8_file(rs_monitor.m3u8,
                         Uploader.new(HLS, destination_presenter))
end

run(m3u8_monitor, ARGV[0], service_name)
