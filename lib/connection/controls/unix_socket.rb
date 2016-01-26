class Connection
  module Controls
    module UNIXSocket
      def self.pair(&block)
        read_io, write_io = ::UNIXSocket.pair

        read_io.sync = true
        read_io.close_write

        write_io.sync = true
        write_io.close_read

        block.(read_io, write_io)
      end
    end
  end
end
