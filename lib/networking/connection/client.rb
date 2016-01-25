module Networking
  module Connection
    class Client
      attr_reader :host
      attr_reader :port
      attr_reader :reconnect_policy
      attr_reader :scheduler

      dependency :logger, Telemetry::Logger

      def initialize(host, port, reconnect_policy, scheduler)
        @host = host
        @port = port
        @reconnect_policy = reconnect_policy
        @scheduler = scheduler
      end

      def self.build(host, port, reconnect_policy: nil, scheduler: nil)
        reconnect_policy ||= :never
        reconnect_policy = ReconnectPolicy.get reconnect_policy

        instance = new host, port, reconnect_policy, scheduler
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
