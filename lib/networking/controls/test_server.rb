module Networking
  module Controls
    class TestServer
      attr_reader :poll_period
      attr_reader :server_socket

      dependency :logger, Telemetry::Logger

      def initialize(server_socket, poll_period)
        @poll_period = poll_period
        @server_socket = server_socket
      end

      def self.build
        logger.trace "Establishing server socket (Port: #{port})"
        server_socket = TCPServer.new '0.0.0.0', port
        logger.debug "Server socket established (Port: #{port})"

        instance = new server_socket, poll_period
        Telemetry::Logger.configure instance
        instance
      end

      def self.call
        instance = build
        instance.()
      end

      def call
        loop do
          logger.trace 'Accepting a connection'
          client = server_socket.accept
          logger.debug 'Client has connected'

          handle_client client

          logger.trace 'Closing connection'
          client.close
          logger.debug 'Connection closed'
        end
      end

      def handle_client(client)
        loop do
          logger.trace 'Reading message from client'
          line = client.readline
          iteration = line.to_i.abs
          logger.debug "Message read from client (Line: #{line.inspect}, Iteration: #{iteration})"

          iteration -= 1

          logger.trace "Writing reply to client (Iteration: #{iteration})"
          client.puts iteration.to_s
          logger.debug "Wrote reply to client (Iteration: #{iteration})"

          break if iteration.zero?
        end

      rescue EOFError
        logger.warn 'EOFError'

      rescue Errno::EPIPE, Errno::ECONNRESET, Errno::EPROTOTYPE
        logger.debug 'Client has closed the connection'
      end

      def self.verify_running
        port = Networking::Controls::TestServer.port
        socket = TCPSocket.new '127.0.0.1', port
        socket.close
      rescue SocketError
        logger.error 'You must run the test server via `ruby lib/networking/controls/test_server/run.rb`'
        exit 1
      end

      def self.logger
        Telemetry::Logger.get self
      end

      def self.poll_period
        2
      end

      def self.port
        Port.example
      end
    end
  end
end
