require_relative './connection_spec_init'

context 'Connection' do
  context 'Writing' do
    data = Connection::Controls::Data.example

    test 'Read until end of file is reached' do
      io = Connection::Controls::IO::Reading.example data
      connection = Connection.build io

      output = connection.read

      assert output == data
    end

    test 'Read a specific amount of data' do
      io = Connection::Controls::IO::Reading.example data
      connection = Connection.build io

      output = connection.read 4

      assert output == data[0...4]
    end

    test 'Read data into an output buffer' do
      io = Connection::Controls::IO::Reading.example data
      buffer = ''
      connection = Connection.build io

      connection.read nil, buffer

      assert buffer == data
    end

    test 'Data is read as ASCII-8BIT (binary)' do
      io = Connection::Controls::IO::Reading.example data
      connection = Connection.build io

      output = connection.read

      assert output.encoding.name == 'ASCII-8BIT'
    end

    context 'Multiple fixed size reads are needed to fully read to EOF' do
      test 'Data exceeds read buffer size' do
        io = Connection::Controls::IO::Reading.example data
        connection = Connection.new io, io, 4

        output = connection.read

        assert output == data
      end

      test 'Interrupted by blocking reads' do
        scheduler = Connection::Controls::Scheduler::Programmable.new

        output = nil

        Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
          connection = Connection.build read_io, scheduler

          scheduler.expect_blocking_read read_io do
            write_io.write data[0...1]
          end
          scheduler.expect_blocking_read read_io do
            write_io.write data[1..-1]
            write_io.close
          end

          output = connection.read
        end

        assert output == data
      end
    end
  end
end
