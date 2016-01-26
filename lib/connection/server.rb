class Connection
  class Server
    attr_reader :socket

    dependency :logger, Telemetry::Logger
    dependency :scheduler, Scheduler

    def initialize(socket)
      @socket = socket
    end

    def self.build(port, bind_address: nil, scheduler: nil, ssl_context: nil)
      bind_address ||= Defaults::BindAddress.get

      if ssl_context
        socket = bind bind_address, port
        ssl_socket = OpenSSL::SSL::SSLServer.new socket, ssl_context
        instance = SSL.new ssl_socket, ssl_context
      else
        socket = bind bind_address, port
        instance = new socket
      end

      Telemetry::Logger.configure instance

      if scheduler
        instance.scheduler = scheduler
      else
        Scheduler.configure instance
      end

      instance
    end

    def self.bind(bind_address, port)
      TCPServer.new bind_address, port
    end

    def accept
      logger.opt_trace "Accepting connection (Fileno: #{fileno})"

      begin
        client_socket = io.accept_nonblock
      rescue IO::WaitReadable
        logger.opt_debug "No connections available (Fileno: #{fileno})"

        logger.opt_trace "Waiting for connection (Fileno: #{fileno})"
        scheduler.wait_readable io
        logger.opt_debug "Incoming connection arrived (Fileno: #{fileno})"

        retry
      end

      logger.opt_debug "Accepted connection (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

      build_connection client_socket
    end

    def accept_socket
      socket.accept_nonblock
    end

    def build_connection(client_socket)
      Connection.build client_socket, scheduler
    end

    def close
      socket.close
    end

    def closed?
      socket.closed?
    end

    def establish_connection
      TCPServer.new bind_address, port
    end

    def fileno
      Fileno.get socket
    end

    def io
      socket
    end

    def socket
      @socket ||= establish_connection
    end

    module Defaults
      module BindAddress
        def self.get
          '127.0.0.1'
        end
      end
    end
  end
end
