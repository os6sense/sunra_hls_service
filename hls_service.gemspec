# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'm3uzi/version'

Gem::Specification.new do |s|
  s.name         = 'hls-service'
  s.version      = M3Uzi2::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['leej@sowhatresearch.com']
  s.email        = ['leej@sowhatresearch.com']
  s.homepage     = 'http://github.com/os6sense/hls_service'
  s.summary      = ''
  s.description  = ''
  s.files        = Dir.glob("lib/**/*") + Dir.glob("spec/**/*") + %w(LICENSE Rakefile README.md)
  s.require_path = 'lib'
end
