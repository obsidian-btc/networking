require_relative './connection_spec_init'

context 'Connection' do
  test 'Closing' do
    socket = StringIO.new
    io = StringIO.new

    connection = Connection.new socket, io, 0

    connection.close

    assert connection.closed?
    assert socket.closed?
    assert io.closed?
  end
end
