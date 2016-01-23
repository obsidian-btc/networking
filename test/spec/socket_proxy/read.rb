require_relative './socket_proxy_spec_init'

context 'Reading From a Socket Proxy' do
  data = Networking::Controls::Data.example

  test 'Read until end of file is reached' do
    io = Networking::Controls::IO::Reading.example data
    socket_proxy = Networking::SocketProxy.build io

    output = socket_proxy.read

    assert output == data
  end

  test 'Read a specific amount of data' do
    io = Networking::Controls::IO::Reading.example data
    socket_proxy = Networking::SocketProxy.build io

    output = socket_proxy.read 4

    assert output == data[0...4]
  end

  test 'Read data into an output buffer' do
    io = Networking::Controls::IO::Reading.example data
    buffer = ''
    socket_proxy = Networking::SocketProxy.build io

    socket_proxy.read nil, buffer

    assert buffer == data
  end

  test 'Data is read as ASCII-8BIT (binary)' do
    io = Networking::Controls::IO::Reading.example data
    socket_proxy = Networking::SocketProxy.build io

    output = socket_proxy.read

    assert output.encoding.name == 'ASCII-8BIT'
  end

  context 'Multiple fixed size reads are needed to fully read to EOF' do
    test 'Data exceeds read buffer size' do
      io = Networking::Controls::IO::Reading.example data
      socket_proxy = Networking::SocketProxy.new io, io, 4

      output = socket_proxy.read

      assert output == data
    end

    test 'Interrupted by blocking reads' do
      dispatcher = Networking::Controls::Scheduler::Cooperative::Dispatcher.new
      scheduler = Networking::Scheduler::Cooperative.build dispatcher

      output = nil

      Networking::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
        socket_proxy = Networking::SocketProxy.build read_io, scheduler

        dispatcher.expect_read read_io do
          write_io.write data[0...1]
        end
        dispatcher.expect_read read_io do
          write_io.write data[1..-1]
          write_io.close
        end

        Networking::Controls::Scheduler::Cooperative::Fiber.run do
          output = socket_proxy.read
        end

        dispatcher.verify
      end

      assert output == data
    end
  end
end
