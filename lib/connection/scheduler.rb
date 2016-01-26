class Connection
  class Scheduler
    dependency :logger, Telemetry::Logger

    def wait_readable(io)
      fileno = Fileno.get io

      logger.opt_trace "Waiting for IO to become readable (Fileno: #{fileno})"

      block_read io

      logger.opt_debug "IO has become readable (Fileno: #{fileno})"
    end

    def wait_writable(io)
      fileno = Fileno.get io

      logger.opt_trace "Waiting for IO to become writable (Fileno: #{fileno})"

      block_write io

      logger.opt_debug "IO has become writable (Fileno: #{fileno})"
    end

    def configure_dependencies
      Telemetry::Logger.configure self
    end

    def self.configure(receiver)
      scheduler = Blocking.build

      receiver.scheduler = scheduler
    end
  end
end
