#!/usr/bin/env ruby

require 'awesome_print'

class Element
  BEGIN_REGEXP = /^BEGIN:([A-Z]+)\s*$/
  ATTR_REGEXP = /^(.+?):(.+)$/
  DESCRIPTION_REGEXP = /^DESCRIPTION:(.*)$/

  def initialize(io, begin_line, output_io = nil)
    raise "Expected a BEGIN line!" unless begin_line =~ BEGIN_REGEXP
    @name = $1

    @io = io
    @begin_line = begin_line
    @output_io = output_io
  end

  def parse
    @body = {}

    @io.each do |line|
      dump(line)

      next if description?(line)

      line.rstrip!
      case line
      when /^END:#{@name}$/
        break
      when BEGIN_REGEXP
        inner = Element.new(@io, line, @output_io).parse
        el_key = inner.keys[0]
        @body[el_key] ||= []
        @body[el_key] << inner[el_key]
      when ATTR_REGEXP
        if @body[$1]
          @body[$1] = [@body[$1]] unless @body[$1].is_a?(Array)
          @body[$1] << $2
        else
          @body[$1] = $2
        end
      else
        raise "Unexpected line: '#{line}'!"
      end
    end

    { @name => @body }
  end

  private

  def description?(line)
    return false unless @parsing_description || description_match = (line =~ DESCRIPTION_REGEXP)

    if @parsing_description
      if line =~ /^ /
        @parsing_description << line
      else
        @parsing_description = @parsing_description[0] if @parsing_description.size == 1
        @body["DESCRIPTION"] = @parsing_description
        @parsing_description = false
      end
    else
      @parsing_description = [$1]
    end
  end

  def dump(line)
    return unless @output_io

    @output_io.puts line
  end
end

class IcalParser
  def self.parse(in_filename, out_filename = nil)
    unless in_filename && File.exist?(in_filename)
      puts "File #{in_filename} doesn't exist!"
      exit 1
    end

    if out_filename
      out = File.open(out_filename, "w")
    end

    File.open(in_filename, "r") do |f|
      first_line = f.gets
      out.puts first_line if out
      root = Element.new(f, first_line, out)
      @parsed = root.parse
    end

    if out_filename
      out.close
    end

    clean_exdates
    clean_rrules

    ap @parsed
  end

  private

  def self.clean_exdates
    @parsed["VCALENDAR"]["VEVENT"].each do |vevent|
      next unless vevent["EXDATE;VALUE=DATE"]

      dates = vevent["EXDATE;VALUE=DATE"]
      dates.sort!
      vevent["EXDATE;VALUE=DATE"] = dates.last
    end
  end

  def self.clean_rrules
    @parsed["VCALENDAR"]["VEVENT"].each do |vevent|
      next unless vevent["DTSTART;VALUE=DATE"] && vevent["DTEND;VALUE=DATE"]

      vevent["RRULE"].sub!(/;UNTIL=\d{8}/, "")
      vevent["RRULE"].sub!(/;BYMONTH=\d{1,2}/, "")
    end
  end
end

IcalParser.parse ARGV[0], ARGV[1]
