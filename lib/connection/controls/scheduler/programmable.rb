class Connection
  module Controls
    module Scheduler
      class Programmable
        def expect_blocking_read(io, &block)
          expected_reads[io] << block
        end

        def expect_blocking_write(io, &block)
          expected_writes[io] << block
        end

        def expected_reads
          @expected_reads ||= Hash.new do |hash, io|
            hash[io] = []
          end
        end

        def expected_writes
          @expected_writes ||= Hash.new do |hash, io|
            hash[io] = []
          end
        end

        def wait_readable(io, &block)
          action = expected_reads[io].shift
          expected_reads.delete io if expected_reads[io].empty?

          unless action
            fail "Did not expect a read on file #{Fileno.get io}"
          end

          action.()
        end

        def wait_writable(io, &block)
          action = expected_writes[io].shift
          expected_writes.delete io if expected_writes[io].empty?

          unless action
            fail "Did not expect a write on file #{Fileno.get io}"
          end

          action.()
        end
      end
    end
  end
end
