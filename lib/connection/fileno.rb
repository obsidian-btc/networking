class Connection
  module Fileno
    def self.get(io)
      case io
      when StringIO then '<stringio>'
      when OpenSSL::SSL::SSLSocket, OpenSSL::SSL::SSLServer then get io.to_io
      when Connection::Substitute then '<substitute>'
      else
        if io.closed?
          '<closed>'
        else
          io.fileno
        end
      end
    end
  end
end
