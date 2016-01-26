class Connection
  class Scheduler
    class Immediate < Scheduler
      def self.build
        instance = new
        instance.configure_dependencies
        instance
      end

      def block_read(io)
      end

      def block_write(io)
      end
    end
  end
end
