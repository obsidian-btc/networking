class Connection
  class Substitute
    module Assertions
      def cannot_read
        raises_io_error do
          read
        end
      end

      def cannot_write(data)
        raises_io_error do
          write data
        end
      end

      def currently_expecting?(expectation_cls)
        expectation_cls === current_expectation
      end

      def raises_io_error(error_class=nil, &block)
        error_class ||= IOError

        block.()
        false
      rescue error_class
        return true
      end
    end
  end
end
