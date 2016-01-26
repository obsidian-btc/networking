module Connection
  class Client
    attr_reader :host
    attr_reader :port
    attr_reader :reconnect_policy
    attr_reader :scheduler
    attr_writer :socket

    dependency :logger, Telemetry::Logger

    def initialize(host, port, reconnect_policy, scheduler)
      @host = host
      @port = port
      @reconnect_policy = reconnect_policy
      @scheduler = scheduler
    end

    def self.build(host, port, reconnect_policy: nil, scheduler: nil, ssl: nil)
      reconnect_policy ||= :never
      reconnect_policy = ReconnectPolicy.get reconnect_policy

      scheduler ||= Scheduler::Blocking.build

      if ssl
        instance = SSL.new host, port, reconnect_policy, scheduler
        instance.ssl_context = ssl if ssl.is_a? OpenSSL::SSL::SSLContext
        instance.ssl_context.verify_mode
      else
        instance = NonSSL.new host, port, reconnect_policy, scheduler
      end

      Telemetry::Logger.configure instance
      instance
    end

    def build_socket_proxy
      logger.trace "Establishing connection (Host: #{host.inspect}, Port: #{port})"

      socket = establish_connection

      logger.debug "Established connection (Host: #{host.inspect}, Port: #{port})"

      SocketProxy.build socket, scheduler
    end

    def close
      socket.close
    end

    def closed?
      socket.closed?
    end

    def connected(&block)
      if socket
        reconnect_policy.control_connection self
      end

      block.(socket)
    end

    def gets(*arguments)
      connected do
        socket.gets *arguments
      end
    end

    def establish_connection
      fail
    end

    def io
      socket.io
    end

    def read(*arguments)
      connected do
        socket.read *arguments
      end
    end

    def readline(*arguments)
      connected do
        socket.readline *arguments
      end
    end

    def reconnect
      self.socket = nil
    end

    def socket
      @socket ||= build_socket_proxy
    end

    def write(*arguments)
      connected do
        socket.write *arguments
      end
    end

    module Assertions
      def reconnects_after_close?
        close

        reconnected = connected do
          !socket.closed?
        end

        close

        reconnected
      end

      def scheduler_configured?(expected_scheduler)
        socket.scheduler == expected_scheduler
      end
    end
  end
end
