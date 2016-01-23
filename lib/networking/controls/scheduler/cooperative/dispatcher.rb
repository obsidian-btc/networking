module Networking
  module Controls
    module Scheduler
      module Cooperative
        class Dispatcher
          def blocks
            @blocks ||= []
          end

          def verify
            if expected_reads.any? || expected_writes.any?
              return false
            end

            blocks.each &:call
            blocks.clear

            true
          end

          def expect_read(io, &block)
            expected_reads[io] = block
          end

          def expect_write(io, &block)
            expected_writes[io] = block
          end

          def expected_reads
            @expected_reads ||= {}
          end

          def expected_writes
            @expected_writes ||= {}
          end

          def wait_readable(io, &block)
            action = expected_reads.delete io

            unless action
              fail "Did not expect a read on file #{Fileno.get io}"
            end

            action.()

            blocks << block
          end

          def wait_writable(io, &block)
            action = expected_writes.delete io

            unless action
              fail "Did not expect a write on file #{Fileno.get io}"
            end

            action.()

            blocks << block
          end
        end
      end
    end
  end
end
