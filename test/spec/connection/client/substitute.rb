require_relative './client_spec_init'

context 'Client Substitute' do
  data = Networking::Controls::Data.example

  context 'Reading' do
    connection = Networking::Connection::Client::Substitute.build
    connection.expect_read data

    output = connection.read

    assert output == data
  end

  context 'Writing' do
    connection = Networking::Connection::Client::Substitute.build
    connection.expect_write data

    connection.write data
  end

  context 'EOF' do
    connection = Networking::Connection::Client::Substitute.build
    connection.eof

    output = connection.gets

    assert output == nil
  end
end
