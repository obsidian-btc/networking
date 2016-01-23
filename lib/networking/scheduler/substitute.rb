module Networking
  class Scheduler
    module Substitute
      def self.build
        Immediate.build
      end
    end
  end
end
