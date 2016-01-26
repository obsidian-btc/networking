class Connection
  class Scheduler
    class Blocking < Scheduler
      attr_reader :timeout

      def initialize(timeout)
        @timeout = timeout
      end

      def self.build(timeout=nil)
        timeout ||= default_timeout

        instance = new timeout
        instance.configure_dependencies
        instance
      end

      def block_read(io)
        loop do
          readable_ios, _, _ = IO.select [io], [], [], timeout
          break if readable_ios == [io]
        end
      end

      def block_write(io)
        loop do
          _, writable_ios, _ = IO.select [], [io], [], timeout
          break if writable_ios == [io]
        end
      end

      def self.default_timeout
        10
      end
    end
  end
end
