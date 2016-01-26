require_relative './connection_spec_init'

context 'Connection' do
  context 'Writing' do
    data = Connection::Controls::Data.example

    test 'Single write transmits all the requested data' do
      io = Connection::Controls::IO::Writing.example
      connection = Connection.build io

      bytes_written = connection.write data

      assert io.string == data
      assert bytes_written == data.bytesize
    end

    test 'Converts input data to a string' do
      input = data.to_sym

      io = Connection::Controls::IO::Writing.example
      connection = Connection.build io

      bytes_written = connection.write input

      assert io.string == data
    end

    context 'Multiple writes are needed to fully write requested data' do
      scheduler = Connection::Controls::Scheduler::Programmable.new
      write_buffer_window_size = Connection::Controls::IO::Scenarios::WritesWillBlock.write_buffer_window_size

      output = nil

      Connection::Controls::IO::Scenarios::WritesWillBlock.activate do |read_io, write_io|
        connection = Connection.build write_io, scheduler

        scheduler.expect_blocking_write write_io do
          read_io.read write_buffer_window_size
        end

        output = connection.write data
      end

      assert output == data.bytesize
    end
  end
end
