module Networking
  module Connection
    class Client
      module ReconnectPolicy
        def self.get(policy_name)
          policy_class = self.policy_class policy_name
          policy_class.new
        end

        def self.logger
          Telemetry::Logger.get self
        end

        def self.policy_class(policy_name=nil)
          policy_name ||= Defaults::Name.get

          policy_class = policies[policy_name]

          unless policy_class
            error_msg = "Refresh policy \"#{policy_name}\" is unknown. It must be one of: never or when_closed."
            logger.error error_msg
            raise Error, error_msg
          end

          policy_class
        end

        def self.policies
          @policies ||= {
            :never => Never,
            :when_closed => WhenClosed
          }
        end

        class Never
          include ReconnectPolicy

          def reconnect?(_)
            false
          end
        end

        class WhenClosed
          include ReconnectPolicy

          def reconnect?(connection)
            connection.closed?
          end
        end

        Error = Class.new StandardError

        module Defaults
          module Name
            def self.get
              :never
            end
          end
        end
      end
    end
  end
end
