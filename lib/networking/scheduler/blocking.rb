module Networking
  module Scheduler
    class Blocking
      attr_reader :timeout

      dependency :logger, Telemetry::Logger

      def initialize(timeout)
        @timeout = timeout
      end

      def self.build(timeout=nil)
        timeout ||= default_timeout

        instance = new timeout
        Telemetry::Logger.configure instance
        instance
      end

      def self.default_timeout
        10
      end

      def wait_readable(io)
        fileno = Fileno.get io

        logger.trace "Waiting for IO to become readable (Fileno: #{fileno}, Timeout: #{timeout.to_f}s)"

        loop do
          readable_ios, _, _ = IO.select [io], [], [], timeout
          break if readable_ios == [io]
        end

        logger.debug "IO has become readable (Fileno: #{fileno}, Timeout: #{timeout.to_f}s)"
      end

      def wait_writable(io)
        fileno = Fileno.get io

        logger.trace "Waiting for IO to become writable (Fileno: #{fileno}, Timeout: #{timeout.to_f}s)"

        loop do
          _, writable_ios, _ = IO.select [], [io], [], timeout
          break if writable_ios == [io]
        end

        logger.debug "IO has become writable (Fileno: #{fileno}, Timeout: #{timeout.to_f}s)"
      end
    end
  end
end
