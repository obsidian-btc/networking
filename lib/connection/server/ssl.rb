class Connection
  class Server
    class SSL < Server
      attr_reader :ssl_context

      def initialize(socket, ssl_context)
        @socket = socket
        @ssl_context = ssl_context
      end

      def accept
        socket.start_immediately = false
        super
      end

      def build_connection(raw_client_socket)
        logger.opt_trace "Building SSL socket (Fileno: #{fileno}, Client Fileno: #{Fileno.get raw_client_socket})"
        client_socket = OpenSSL::SSL::SSLSocket.new raw_client_socket, ssl_context
        logger.opt_debug "Built SSL socket (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

        logger.opt_trace "Performing SSL handshake (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

        begin
          client_socket.accept_nonblock
        rescue IO::WaitReadable
          logger.opt_debug "Client not ready for handshake; deferring (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

          logger.opt_debug "Waiting for client to be ready for handshake (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"
          scheduler.wait_readable client_socket.to_io
          logger.opt_debug "Client ready for handshake (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

          retry
        end

        logger.opt_debug "Performed SSL handshake (Fileno: #{fileno}, Client Fileno: #{Fileno.get client_socket})"

        Connection.build client_socket, scheduler
      end

      def io
        socket.to_io
      end
    end
  end
end
