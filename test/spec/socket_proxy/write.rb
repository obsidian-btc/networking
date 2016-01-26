require_relative './socket_proxy_spec_init'

context 'Socket Proxy' do
  context 'Writing' do
    data = Connection::Controls::Data.example

    test 'Single write transmits all the requested data' do
      io = Connection::Controls::IO::Writing.example
      socket_proxy = Connection::SocketProxy.build io

      bytes_written = socket_proxy.write data

      assert io.string == data
      assert bytes_written == data.bytesize
    end

    context 'Multiple writes are needed to fully write requested data' do
      dispatcher = Connection::Controls::Scheduler::Cooperative::Dispatcher.new
      scheduler = Connection::Scheduler::Cooperative.build dispatcher
      write_buffer_window_size = Connection::Controls::IO::Scenarios::WritesWillBlock.write_buffer_window_size

      output = nil

      Connection::Controls::IO::Scenarios::WritesWillBlock.activate do |read_io, write_io|
        socket_proxy = Connection::SocketProxy.build write_io, scheduler

        dispatcher.expect_write write_io do
          read_io.read write_buffer_window_size
        end

        Connection::Controls::Scheduler::Cooperative::Fiber.run do
          output = socket_proxy.write data
        end

        dispatcher.verify
      end

      assert output == data.bytesize
    end
  end
end
