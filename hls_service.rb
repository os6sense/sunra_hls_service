#!/usr/bin/env ruby

# File::sunra-failsafe.rb
#
# Description::
# Failsafe uses a simple capturer to record and *bypasses*
# the recording service. Whilst this leads to some code duplication
# if the recorder-service fails for any reason it is hoped that a
# basic capture thread will remain immune.

# The original version of failsafe had MP3 and MP4 versions. Given the
# ease with which audio can be extracted, a single MP4 recorder is
# used for the failsafe service.
#
#
require "sunra_config/hls"
require_relative "hls"

require_relative '../lib/service'

include Service

service_name = "hls-service.rb"

usage service_name if ARGV.length != 1

fs_rec = Sunra::Recording::HLS.new(Sunra::Config::HLS.new)

run(fs_rec, ARGV[0], "failsafe service.rb")
