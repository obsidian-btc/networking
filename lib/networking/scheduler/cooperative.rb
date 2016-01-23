module Networking
  module Scheduler
    class Cooperative
      attr_reader :dispatcher

      dependency :logger, Telemetry::Logger

      def initialize(dispatcher)
        @dispatcher = dispatcher
      end

      def self.build(dispatcher)
        instance = new dispatcher
        Telemetry::Logger.configure instance
        instance
      end

      def wait_readable(io)
        fileno = Fileno.get io
        logger.trace "Waiting for IO to become readable (Fileno: #{fileno})"

        fiber = Fiber.current

        dispatcher.wait_readable io do
          fiber.resume
        end

        Fiber.yield

        logger.debug "IO has become readable (Fileno: #{fileno})"
      end

      def wait_writable(io)
        fileno = Fileno.get io
        logger.trace "Waiting for IO to become writable (Fileno: #{fileno})"

        fiber = Fiber.current

        dispatcher.wait_writable io do
          fiber.resume
        end

        Fiber.yield

        logger.debug "IO has become writable (Fileno: #{fileno})"
      end
    end
  end
end
