module Networking
  module Controls
    module Scheduler
      module Cooperative
        module Fiber
          def self.run(&block)
            fiber = ::Fiber.new &block
            fiber.resume
          end
        end
      end
    end
  end
end
