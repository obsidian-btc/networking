module Networking
  module Connection
    class Client
      class NonSSL < Client
        def establish_connection
          TCPSocket.new host, port
        end
      end
    end
  end
end