class Connection
  module Controls
    module UNIXSocket
      module Assertions
        def read_would_block?
          read_nonblock 1
          return false
        rescue ::IO::WaitReadable
          return true
        end

        def write_would_block?
          write_nonblock "\x00"
          return false
        rescue ::IO::WaitWritable
          return true
        end
      end
    end
  end
end
