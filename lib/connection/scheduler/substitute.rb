module Connection
  class Scheduler
    module Substitute
      def self.build
        Immediate.build
      end
    end
  end
end
