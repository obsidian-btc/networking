module Connection
  module Connection
    class Client
      class Substitute < Client
        def self.build
          reconnect_policy = ReconnectPolicy.get :never
          scheduler = Scheduler::Substitute.build

          instance = new '<substitute>', 0, reconnect_policy, scheduler
          Telemetry::Logger.configure instance
          instance
        end

        def build_socket_proxy
          SocketProxy::Substitute.build
        end

        def eof
          socket.eof
        end

        def expect_read(data)
          socket.expect_read data
        end

        def expect_write(data)
          socket.expect_write data
        end
      end
    end
  end
end
