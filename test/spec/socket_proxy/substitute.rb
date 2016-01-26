require_relative './socket_proxy_spec_init'

context 'Socket Proxy Substitute' do
  data = Connection::Controls::Data.example

  context 'Reading' do
    context 'Expected' do
      test 'Unspecified Length' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_read data

        output = socket_proxy.read

        assert output == data
      end

      test 'Specific Length' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_read data

        output = socket_proxy.read 4

        assert output == data[0...4]
      end
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build

        assert socket_proxy do
          cannot_read
        end
      end

      test 'Write is Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_write Data

        assert socket_proxy do
          cannot_read
        end
      end
    end
  end

  context 'Reading a Line' do
    test 'Expected' do
      multiline_data = Connection::Controls::Data::PlainText::MultipleLines.example

      socket_proxy = Connection::SocketProxy::Substitute.build
      socket_proxy.expect_read multiline_data

      output = String.new
      output << socket_proxy.readline
      output << socket_proxy.readline

      assert output == multiline_data
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build

        assert socket_proxy do
          raises_io_error do
            socket_proxy.readline
          end
        end
      end

      test 'Write is Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_write data

        assert socket_proxy do
          raises_io_error do
            socket_proxy.readline
          end
        end
      end
    end
  end

  context 'Writing' do
    context 'Expected' do
      test 'In Full' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_write data

        socket_proxy.write data

        assert socket_proxy do
          currently_expecting? Connection::SocketProxy::Substitute::Expectation::None
        end
      end

      test 'Partial' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_write data

        socket_proxy.write data[0..1]

        assert socket_proxy do
          currently_expecting? Connection::SocketProxy::Substitute::Expectation::Write
        end
      end
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build

        assert socket_proxy do
          cannot_write data
        end
      end

      test 'Different Text is Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_write data

        assert socket_proxy do
          cannot_write data.reverse
        end
      end

      test 'Read is Programmed' do
        socket_proxy = Connection::SocketProxy::Substitute.build
        socket_proxy.expect_read data

        assert socket_proxy do
          cannot_write data
        end
      end
    end
  end

  context 'EOF (remote end closes connection)' do
    test 'gets returns nil' do
      socket_proxy = Connection::SocketProxy::Substitute.build
      socket_proxy.eof

      output = socket_proxy.gets

      assert output == nil
    end

    test 'readline raises EOFError' do
      socket_proxy = Connection::SocketProxy::Substitute.build
      socket_proxy.eof

      assert socket_proxy do
        raises_io_error EOFError do
          socket_proxy.readline
        end
      end
    end

    test 'read returns an empty string' do
      socket_proxy = Connection::SocketProxy::Substitute.build
      socket_proxy.eof

      output = socket_proxy.read

      assert output == ''
    end

    test 'write raises Errno::EPIPE' do
      socket_proxy = Connection::SocketProxy::Substitute.build
      socket_proxy.eof

      assert socket_proxy do
        raises_io_error Errno::EPIPE do
          socket_proxy.write data
        end
      end
    end
  end

  test 'Closing' do
    socket_proxy = Connection::SocketProxy::Substitute.build

    assert !socket_proxy.closed?

    socket_proxy.close

    assert socket_proxy.closed?
  end
end
