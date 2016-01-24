require_relative './socket_proxy_spec_init'

context 'Socket Proxy' do
  assert $INPUT_RECORD_SEPARATOR == "\n"

  context 'Reading a line of text (gets)' do
    test do
      data = Networking::Controls::Data::PlainText::MultipleLines.example
      first_line = data.each_line.first
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.gets

      assert output == first_line
    end

    test 'Separator defaults to input record separator ($/) when not set' do
      data = Networking::Controls::Data::PlainText::MultipleLines.example "\r"
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.gets

      assert output == data
    end

    test 'Separator explicitly set to nil causes a full read through EOF' do
      data = Networking::Controls::Data::PlainText::MultipleLines.example
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.gets nil

      assert output == data
    end

    test 'Zero length separator ("") splits on paragraphs' do
      data = Networking::Controls::Data::PlainText::MultipleLines.example "\n\n"
      first_line = data.each_line("\n\n").first
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.gets ''

      assert output == first_line
    end

    test 'Byte limit is specified and separator is not' do
      data = Networking::Controls::Data::PlainText::SingleLine.example
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.gets 1

      assert output == data[0]
    end

    context 'Byte limit and separator are both specified' do
      separator = "\r"
      data = Networking::Controls::Data::PlainText::MultipleLines.example separator

      test 'Byte limit is reached first' do
        io = Networking::Controls::IO::Reading.example data

        socket_proxy = Networking::SocketProxy.build io

        output = socket_proxy.gets separator, 1

        assert output == data[0]
      end

      test 'Separator is reached first' do
        first_line = data.each_line(separator).first
        io = Networking::Controls::IO::Reading.example data

        socket_proxy = Networking::SocketProxy.build io

        output = socket_proxy.gets separator, data.bytesize

        assert output == first_line
      end
    end

    test 'Call would block' do
      data = Networking::Controls::Data::PlainText::SingleLine.example
      dispatcher = Networking::Controls::Scheduler::Cooperative::Dispatcher.new
      scheduler = Networking::Scheduler::Cooperative.build dispatcher

      output = nil

      Networking::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
        socket_proxy = Networking::SocketProxy.build read_io, scheduler

        dispatcher.expect_read read_io do
          write_io.write data
        end

        Networking::Controls::Scheduler::Cooperative::Fiber.run do
          output = socket_proxy.gets
        end

        dispatcher.verify
      end

      assert output == data
    end

    test 'After remote connection is closed' do
      data = Networking::Controls::Data::PlainText::SingleLine.example
      dispatcher = Networking::Controls::Scheduler::Cooperative::Dispatcher.new
      scheduler = Networking::Scheduler::Cooperative.build dispatcher

      output = :not_nil

      Networking::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
        socket_proxy = Networking::SocketProxy.build read_io, scheduler

        dispatcher.expect_read read_io do
          write_io.close
        end

        Networking::Controls::Scheduler::Cooperative::Fiber.run do
          output = socket_proxy.gets
        end

        dispatcher.verify
      end

      assert output.nil?
    end
  end

  context 'readline variation' do
    test do
      data = Networking::Controls::Data::PlainText::SingleLine.example
      io = Networking::Controls::IO::Reading.example data

      socket_proxy = Networking::SocketProxy.build io

      output = socket_proxy.readline

      assert output == data
    end

    test 'EOFError is raised after remote connection is closed' do
      io = StringIO.new

      socket_proxy = Networking::SocketProxy.build io

      begin
        socket_proxy.readline
      rescue EOFError => error
      end

      assert error
    end
  end
end
