module Networking
  class Scheduler
    class Substitute < Immediate
      attr_accessor :sink

      def self.build
        substitute_scheduler = new
        substitute_scheduler.configure_dependencies

        sink = Scheduler.register_telemetry_sink substitute_scheduler
        substitute_scheduler.sink = sink

        substitute_scheduler
      end
    end
  end
end
