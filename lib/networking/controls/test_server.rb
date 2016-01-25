module Networking
  module Controls
    class TestServer
      attr_reader :poll_period
      attr_reader :server_sockets

      dependency :logger, Telemetry::Logger

      def initialize(server_sockets, poll_period)
        @poll_period = poll_period
        @server_sockets = server_sockets
      end

      def self.build
        logger.trace "Establishing server socket (Unencrypted Port: #{port}, SSL Port: #{ssl_port})"

        server_socket = TCPServer.new '0.0.0.0', port

        ssl_context = SSL::Context::Server.example
        ssl_server_raw_socket = TCPServer.new '0.0.0.0', ssl_port
        ssl_server_socket = OpenSSL::SSL::SSLServer.new ssl_server_raw_socket, ssl_context

        logger.debug "Server sockets established (Unencrypted Port: #{port}, SSL Port: #{ssl_port})"

        instance = new [server_socket, ssl_server_socket], poll_period
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
          reads, * = select

          if reads.nil?
            logger.debug 'No client has connected'
            next
          end

          logger.debug "Client has connected (Count: #{reads.size})"

          reads.each do |server_socket|
            logger.trace 'Accepting client'
            client = server_socket.accept
            logger.debug "Accepted client (Type: #{client.class.name.inspect})"

            handle_client client

            logger.trace 'Closing connection'
            client.close
            logger.debug 'Connection closed'
          end
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

      def select
        raw_sockets = server_sockets.map do |server_socket|
          if server_socket.respond_to? :to_io
            server_socket.to_io
          else
            server_socket
          end
        end

        ::IO.select raw_sockets, [], [], poll_period
      end

      def self.verify_running
        socket = TCPSocket.new '127.0.0.1', port

        ssl_context = SSL::Context::Client.example
        raw_ssl_socket = TCPSocket.new '127.0.0.1', ssl_port
        ssl_socket = OpenSSL::SSL::SSLSocket.new raw_ssl_socket, ssl_context

      rescue SocketError
        logger.error 'You must run the test server via `ruby lib/networking/controls/test_server/run.rb`'
        exit 1

      ensure
        socket.close if socket
        raw_ssl_socket.close if raw_ssl_socket
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

      def self.ssl_port
        port + 1
      end
    end
  end
end
