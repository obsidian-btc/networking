require_relative './socket_proxy_spec_init'

context 'Writing To a Socket Proxy' do
  data = Networking::Controls::Data.example

  test 'Single write transmits all the requested data' do
    io = Networking::Controls::IO::Writing.example
    socket_proxy = Networking::SocketProxy.build io

    bytes_written = socket_proxy.write data

    assert io.string == data
    assert bytes_written == data.bytesize
  end

  context 'Multiple writes are needed to fully write requested data' do
    dispatcher = Networking::Controls::Scheduler::Cooperative::Dispatcher.new
    scheduler = Networking::Scheduler::Cooperative.build dispatcher
    write_buffer_window_size = Networking::Controls::IO::Scenarios::WritesWillBlock.write_buffer_window_size

    output = nil

    Networking::Controls::IO::Scenarios::WritesWillBlock.activate do |read_io, write_io|
      socket_proxy = Networking::SocketProxy.build write_io, scheduler

      dispatcher.expect_write write_io do
        read_io.read write_buffer_window_size
      end

      Networking::Controls::Scheduler::Cooperative::Fiber.run do
        output = socket_proxy.write data
      end

      dispatcher.verify
    end

    assert output == data.bytesize
  end
end
