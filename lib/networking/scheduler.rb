module Networking
  class Scheduler
    dependency :logger, ::Telemetry::Logger
    dependency :telemetry, ::Telemetry

    def wait_readable(io)
      fileno = Fileno.get io

      logger.trace "Waiting for IO to become readable (Fileno: #{fileno})"
      telemetry.record :read_scheduled, io

      block_read io

      logger.debug "IO has become readable (Fileno: #{fileno})"
    end

    def wait_writable(io)
      fileno = Fileno.get io

      logger.trace "Waiting for IO to become writable (Fileno: #{fileno})"
      telemetry.record :write_scheduled, io

      block_write io

      logger.debug "IO has become writable (Fileno: #{fileno})"
    end

    def configure_dependencies
      ::Telemetry::Logger.configure self
      ::Telemetry.configure self
    end

    def self.configure(receiver)
      scheduler = Blocking.build

      receiver.scheduler = scheduler
    end

    def self.register_telemetry_sink(scheduler)
      sink = Telemetry.sink
      scheduler.telemetry.register sink
      sink
    end

    module Telemetry
      class Sink
        include ::Telemetry::Sink

        record :read_scheduled
        record :write_scheduled
      end

      def self.sink
        Sink.new
      end
    end
  end
end
