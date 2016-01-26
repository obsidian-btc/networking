class Connection
  module Controls
    module IO
      module Scenarios
        module DeferViaThread
          def self.call(timeout, &block)
            thread = Thread.new do
              thread.abort_on_exception = true
              sleep timeout
              block.()
            end

            Thread.pass until thread.status == 'sleep'

            thread
          end
        end

        module ReadsWillBlock
          def self.activate(&block)
            UNIXSocket.pair do |read_io, write_io|
              block.(read_io, write_io)
            end
          end
        end

        module WritesWillBlock
          def self.activate(&block)
            UNIXSocket.pair do |read_io, write_io|
              fill_write_buffer write_io
              block.(read_io, write_io)
            end
          end

          def self.fill_write_buffer(io)
            loop do
              io.write_nonblock "\x00"
            end

          rescue ::IO::WaitWritable
          end

          def self.write_buffer_window_size
            # This was tested on Nathan's laptop, I haven't determined a viable
            # strategy for programmatically determining this value. Essentially,
            # when you fill the write buffer of one end of a pair of UNIX
            # sockets, this method should return the number of bytes that must
            # be read before the subsequent write will not block.
            2048
          end
        end
      end
    end
  end
end
