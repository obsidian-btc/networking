require_relative './connection_spec_init'

context 'Connection Substitute' do
  data = Connection::Controls::Data.example

  context 'Reading' do
    context 'Expected' do
      test 'Unspecified Length' do
        connection = Connection::Substitute.build
        connection.expect_read data

        output = connection.read

        assert output == data
      end

      test 'Specific Length' do
        connection = Connection::Substitute.build
        connection.expect_read data

        output = connection.read 4

        assert output == data[0...4]
      end
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        connection = Connection::Substitute.build

        assert connection do
          cannot_read
        end
      end

      test 'Write is Programmed' do
        connection = Connection::Substitute.build
        connection.expect_write Data

        assert connection do
          cannot_read
        end
      end
    end
  end

  context 'Reading a Line' do
    test 'Expected' do
      multiline_data = Connection::Controls::Data::PlainText::MultipleLines.example

      connection = Connection::Substitute.build
      connection.expect_read multiline_data

      output = String.new
      output << connection.readline
      output << connection.readline

      assert output == multiline_data
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        connection = Connection::Substitute.build

        assert connection do
          raises_io_error do
            connection.readline
          end
        end
      end

      test 'Write is Programmed' do
        connection = Connection::Substitute.build
        connection.expect_write data

        assert connection do
          raises_io_error do
            connection.readline
          end
        end
      end
    end
  end

  context 'Writing' do
    context 'Expected' do
      test 'In Full' do
        connection = Connection::Substitute.build
        connection.expect_write data

        connection.write data

        assert connection do
          currently_expecting? Connection::Substitute::Expectation::None
        end
      end

      test 'Partial' do
        connection = Connection::Substitute.build
        connection.expect_write data

        connection.write data[0..1]

        assert connection do
          currently_expecting? Connection::Substitute::Expectation::Write
        end
      end
    end

    context 'Unexpected' do
      test 'Nothing Programmed' do
        connection = Connection::Substitute.build

        assert connection do
          cannot_write data
        end
      end

      test 'Different Text is Programmed' do
        connection = Connection::Substitute.build
        connection.expect_write data

        assert connection do
          cannot_write data.reverse
        end
      end

      test 'Read is Programmed' do
        connection = Connection::Substitute.build
        connection.expect_read data

        assert connection do
          cannot_write data
        end
      end
    end
  end

  context 'EOF (remote end closes connection)' do
    test 'gets returns nil' do
      connection = Connection::Substitute.build
      connection.eof

      output = connection.gets

      assert output == nil
    end

    test 'readline raises EOFError' do
      connection = Connection::Substitute.build
      connection.eof

      assert connection do
        raises_io_error EOFError do
          connection.readline
        end
      end
    end

    test 'read returns an empty string' do
      connection = Connection::Substitute.build
      connection.eof

      output = connection.read

      assert output == ''
    end

    test 'write raises Errno::EPIPE' do
      connection = Connection::Substitute.build
      connection.eof

      assert connection do
        raises_io_error Errno::EPIPE do
          connection.write data
        end
      end
    end
  end

  test 'Closing' do
    connection = Connection::Substitute.build

    assert !connection.closed?

    connection.close

    assert connection.closed?
  end
end
