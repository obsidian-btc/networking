class Connection
  class Substitute
    class Expectation < Struct.new :data
      dependency :logger, Telemetry::Logger

      def self.build(data=nil)
        instance = new data
        ::Telemetry::Logger.configure instance
        instance
      end

      def eof?
        io.eof?
      end

      def io
        @io ||= build_io
      end

      def read(*arguments)
        io.read *arguments
      end

      def readline(*arguments)
        io.readline *arguments
      end

      def write(data)
        io.write data
      end

      module Expectation::EOF
        def self.eof?
          true
        end

        def self.read
          ''
        end

        def self.readline
          raise EOFError
        end

        def self.write(data)
          raise Errno::EPIPE
        end
      end

      class Expectation::None < Expectation
        def self.instance
          @instance ||= build
        end

        def build_io
          io = StringIO.new
          io.close_read
          io.close_write
          io
        end
      end

      class Expectation::Read < Expectation
        def build_io
          io = StringIO.new data
          io.close_write
          io
        end
      end

      class Expectation::Write < Expectation
        def build_io
          io = StringIO.new
          io.close_read
          io
        end

        def verify_written
          unless data.start_with? io.string
            logger.fail 'Did not write the expected data; expected:'
            logger.fail data
            logger.fail 'Actual:'
            logger.fail io.string
            logger.fail ''

            raise IOError
          end
        end

        def finished?
          io.string == data
        end
      end
    end
  end
end
