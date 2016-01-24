ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'
ENV['LOG_LEVEL'] ||= 'trace'

puts RUBY_DESCRIPTION

require_relative '../init.rb'

require 'test_bench'; TestBench.activate

require 'networking/controls'

class UNIXSocket
  module Assertions
    def read_would_block?
      read_nonblock 1
      return false
    rescue IO::WaitReadable
      return true
    end

    def write_would_block?
      write_nonblock "\x00"
      return false
    rescue IO::WaitWritable
      return true
    end
  end
end

Telemetry::Logger::AdHoc.activate
