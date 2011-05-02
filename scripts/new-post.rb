#!/usr/bin/env ruby

if ARGV.first == '-h' || ARGV.first == '--help' || ARGV.empty?
  STDERR.puts "Usage:"
  STDERR.puts "  #{__FILE__} \"Title of post\""
  abort
end

require 'fileutils'

Dir.chdir(File.join(File.dirname(__FILE__), '..', '_posts'))

filename = ["#{Time.new.strftime('%Y-%m-%d')} #{ARGV.first}".gsub(/\W/,'-').downcase, 'markdown'].join('.')

FileUtils.touch filename
