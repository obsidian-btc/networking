require_relative './scheduler_spec_init'

context 'Blocking Scheduler' do
  timeout = Connection::Controls::IO::Timeout.short
  octet = Connection::Controls::IO::Octet.example
  write_buffer_window_size = Connection::Controls::IO::Scenarios::WritesWillBlock.write_buffer_window_size

  scheduler = Connection::Scheduler::Blocking.build timeout

  test 'Scheduling a read' do
    Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
      thread = Connection::Controls::IO::Scenarios::DeferViaThread.(timeout * 2) do
        write_io.write octet
      end

      scheduler.wait_readable read_io

      assert read_io, Connection::Controls::UNIXSocket::Assertions do
        !read_would_block?
      end

      thread.join
    end
  end

  test 'Scheduling a write' do
    Connection::Controls::IO::Scenarios::WritesWillBlock.activate do |read_io, write_io|
      thread = Connection::Controls::IO::Scenarios::DeferViaThread.(timeout * 2) do
         read_io.read write_buffer_window_size
      end

      scheduler.wait_writable write_io

      assert write_io, Connection::Controls::UNIXSocket::Assertions do
        !write_would_block?
      end
    end
  end
end
