require_relative './client_spec_init'

context 'Client Connection' do
  host = Networking::Controls::Host::Localhost.example
  port = Networking::Controls::TestServer.ssl_port
  ssl_context = Networking::Controls::SSL::Context::Client.example

  context 'SSL' do
    test 'Reading and writing' do
      iteration = 1
      client = Networking::Connection::Client.build host, port, ssl_context: ssl_context

      client.write "#{iteration}\n"
      response = client.read

      assert response == "0\n"
    end
  end
end
