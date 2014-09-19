# -*- encoding: utf-8 -*-
#lib = File.expand_path('../lib/', __FILE__)
#$:.unshift lib unless $:.include?(lib)

require_relative 'version'

Gem::Specification.new do |s|
  s.name         = 'hls-service'
  s.version      = VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['leej@sowhatresearch.com']
  s.email        = ['leej@sowhatresearch.com']
  s.homepage     = 'http://github.com/os6sense/hls_service'
  s.summary      = 'Simple HLS uploader service for live streams'
  s.description  = 'Simple HLS uploader service for live streams'
  s.files        = Dir.glob("lib/**/*") + Dir.glob("spec/**/*") + %w(LICENSE Rakefile README.md)
  s.require_path = 'lib'
end
