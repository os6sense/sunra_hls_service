#!/usr/bin/env ruby

# File:: hls_service
#
# Description::
#
require "sunra_config/hls"
require 'sunra_service'

require_relative 'hls_uploader'
require_relative 'recording_service_monitor'
require_relative 'destination_presenter'
require_relative "m3u8_monitor"

include SunraService

service_name = "hls_service.rb"
usage service_name if ARGV.length != 1

config = Sunra::Config::HLS
dest_pres = SunraArchiveDestinationPresenter.new
rsm = RecordingServiceMonitor.new(config.recording_server_api_key,
                                  config.recording_server_rest_url)

monitor = M3U8Monitor.new(config, rsm) do | mon |
  dest_pres.set_ids(rsm)
  @uploader = HLSUploader.new(config, dest_pres)
  mon.monitor_m3u8_file(rsm.m3u8, @uploader)
end

run(monitor, ARGV[0], "hls_service.rb")
