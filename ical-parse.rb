#!/usr/bin/env ruby

require 'awesome_print'
#require 'minitest/autorun'

file = ARGV[0]

unless File.exist?(file)
  puts "File #{file} doesn't exist!"
  exit 1
end

class Element
  BEGIN_REGEXP = /^BEGIN:([A-Z]+)\s*$/
  ATTR_REGEXP = /^(.+):(.+)$/

  def initialize(io, begin_line)
    raise "Expected a BEGIN line!" unless begin_line =~ BEGIN_REGEXP
    @name = $1

    @io = io
    @begin_line = begin_line
  end

  def parse
    @body = {}

    @io.each do |line|
      line.strip!
      case line
      when /^END:#{@name}$/
        break
      when BEGIN_REGEXP
        inner = Element.new(@io, line).parse
        el_key = inner.keys[0]
        @body[el_key] ||= []
        @body[el_key] << inner[el_key]
      when ATTR_REGEXP
        @body[$1] = $2
      else
        raise "Unexpected line: '#{line}'!"
      end
    end

    { @name => @body }
  end
end

File.open(file, "r") do |f|
  root = Element.new(f, f.gets)
  ap root.parse
end

#require 'optparse'

#options = {}
#
#option_parser = OptionParser.new do |opts|
#  # Create a switch
#  opts.on("-i", "--iteration") do
#    options[:iteration] = true
#  end
#  # Create a flag
#  opts.on("-u USER") do |user|'
#    options[:user] = user
#  end
#  opts.on("-p PASSWORD") do |password|
#    options[:password] = password
#  end
#end
#
#option_parser.parse!
#puts options.inspect

