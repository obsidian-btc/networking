module Networking
  module Connection
    class Client
      attr_reader :host
      attr_reader :port
      attr_reader :reconnect_policy
      attr_reader :scheduler
      attr_reader :ssl_context

      dependency :logger, Telemetry::Logger

      def initialize(host, port, reconnect_policy, scheduler, ssl_context)
        @host = host
        @port = port
        @reconnect_policy = reconnect_policy
        @scheduler = scheduler
        @ssl_context = ssl_context
      end

      def self.build(host, port, reconnect_policy: nil, scheduler: nil, ssl_context: nil)
        reconnect_policy ||= :never
        reconnect_policy = ReconnectPolicy.get reconnect_policy

        scheduler ||= Scheduler::Blocking.build

        instance = new host, port, reconnect_policy, scheduler, ssl_context
        Telemetry::Logger.configure instance
        instance
      end

      def close
        socket.close
      end

      def closed?
        socket.closed?
      end

      def gets(*arguments)
        socket.gets *arguments
      end

      def establish_connection
        logger.trace "Establishing connection (Host: #{host.inspect}, Port: #{port})"

        socket = TCPSocket.new host, port
        if ssl_context
          logger.trace "Enabling SSL (Host: #{host.inspect}, Port: #{port}, Fileno: #{Fileno.get socket})"
          raw_socket = socket
          socket = OpenSSL::SSL::SSLSocket.new raw_socket, ssl_context

          loop do
            result = socket.connect_nonblock :exception => false
            if result == :wait_readable
              logger.trace "Not ready for SSL handshake; deferring (Host: #{host.inspect}, Port: #{port}, Fileno: #{Fileno.get socket})"
              scheduler.wait_readable raw_socket
              logger.debug "Ready for SSL handshake (Host: #{host.inspect}, Port: #{port}, Fileno: #{Fileno.get socket})"
              next
            end
            break
          end

          logger.debug "SSL enabled (Host: #{host.inspect}, Port: #{port}, Fileno: #{Fileno.get socket})"
        end
        socket_proxy = SocketProxy.build socket, scheduler

        logger.trace "Established connection (Host: #{host.inspect}, Port: #{port})"

        socket_proxy
      end

      def read(*arguments)
        socket.read *arguments
      end

      def readline(*arguments)
        socket.readline *arguments
      end

      def socket
        if @socket
          @socket = nil if reconnect_policy.reconnect? @socket
        end

        @socket ||= establish_connection
      end

      def write(*arguments)
        socket.write *arguments
      end

      module Assertions
        def reconnects_after_close?
          close

          reconnected = !socket.closed?

          close

          reconnected
        end

        def scheduler_configured?(expected_scheduler)
          socket.scheduler == expected_scheduler
        end
      end
    end
  end
end
