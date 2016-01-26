require_relative './scheduler_spec_init'

context 'Immediate Scheduler' do
  scheduler = Connection::Scheduler::Immediate.new

  test 'Scheduling a read' do
    Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |io, _|
      scheduler.wait_readable io

      assert io, Connection::Controls::UNIXSocket::Assertions do
        read_would_block?
      end
    end
  end

  test 'Scheduling a write' do
    Connection::Controls::IO::Scenarios::WritesWillBlock.activate do |_, io|
      scheduler.wait_writable io

      assert io, Connection::Controls::UNIXSocket::Assertions do
        write_would_block?
      end
    end
  end
end
