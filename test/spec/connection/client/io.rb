require_relative './client_spec_init'

context 'Client Connection' do
  host = Connection::Controls::Host::Localhost.example
  port = Connection::Controls::TestServer.port

  context 'I/O' do
    test 'Reading and writing' do
      iteration = 1
      client = Connection::Client.build host, port

      client.write "#{iteration}\n"
      response = client.read

      assert response == "0\n"
    end

    test 'Reading a single line' do
      iteration = 2
      client = Connection::Client.build host, port

      client.write "#{iteration}\n"
      response = client.gets

      assert response == "1\n"
    end
  end
end
