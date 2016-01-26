require_relative './connection_spec_init'

context 'Connection' do
  assert $INPUT_RECORD_SEPARATOR == "\n"

  context 'Reading a line of text (gets)' do
    test do
      data = Connection::Controls::Data::PlainText::MultipleLines.example
      first_line = data.each_line.first
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.gets

      assert output == first_line
    end

    test 'Separator defaults to input record separator ($/) when not set' do
      data = Connection::Controls::Data::PlainText::MultipleLines.example "\r"
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.gets

      assert output == data
    end

    test 'Separator explicitly set to nil causes a full read through EOF' do
      data = Connection::Controls::Data::PlainText::MultipleLines.example
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.gets nil

      assert output == data
    end

    test 'Zero length separator ("") splits on paragraphs' do
      data = Connection::Controls::Data::PlainText::MultipleLines.example "\n\n"
      first_line = data.each_line("\n\n").first
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.gets ''

      assert output == first_line
    end

    test 'Byte limit is specified and separator is not' do
      data = Connection::Controls::Data::PlainText::SingleLine.example
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.gets 1

      assert output == data[0]
    end

    context 'Byte limit and separator are both specified' do
      separator = "\r"
      data = Connection::Controls::Data::PlainText::MultipleLines.example separator

      test 'Byte limit is reached first' do
        io = Connection::Controls::IO::Reading.example data

        connection = Connection.build io

        output = connection.gets separator, 1

        assert output == data[0]
      end

      test 'Separator is reached first' do
        first_line = data.each_line(separator).first
        io = Connection::Controls::IO::Reading.example data

        connection = Connection.build io

        output = connection.gets separator, data.bytesize

        assert output == first_line
      end
    end

    test 'Call would block' do
      data = Connection::Controls::Data::PlainText::SingleLine.example
      scheduler = Connection::Controls::Scheduler::Programmable.new

      output = nil

      Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
        connection = Connection.build read_io, scheduler

        scheduler.expect_blocking_read read_io do
          write_io.write data
        end

        output = connection.gets
      end

      assert output == data
    end

    test 'After remote connection is closed' do
      data = Connection::Controls::Data::PlainText::SingleLine.example
      scheduler = Connection::Controls::Scheduler::Programmable.new

      output = :not_nil

      Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
        connection = Connection.build read_io, scheduler

        scheduler.expect_blocking_read read_io do
          write_io.close
        end

        output = connection.gets
      end

      assert output.nil?
    end
  end

  context 'readline variation' do
    test do
      data = Connection::Controls::Data::PlainText::SingleLine.example
      io = Connection::Controls::IO::Reading.example data

      connection = Connection.build io

      output = connection.readline

      assert output == data
    end

    test 'EOFError is raised after remote connection is closed' do
      io = StringIO.new

      connection = Connection.build io

      begin
        connection.readline
      rescue EOFError => error
      end

      assert error
    end
  end
end
