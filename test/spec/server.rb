context 'Server' do
  data = Networking::Controls::Data.example
  port = Networking::Controls::Port.example
  host = Networking::Controls::Host::Localhost.example

  test 'Accepting a connection' do
    server = Networking::Server.build port

    client = TCPSocket.new host, port

    begin
      connection = server.accept

      client.write data
      client.close

      output = connection.read
      connection.close

      assert output == data

    ensure
      connection.close if connection
      server.close if server
      client.close if client
    end
  end

  test 'Setting scheduler on client' do
    scheduler = Networking::Scheduler::Immediate.build
    server = Networking::Server.build port, :scheduler => scheduler

    client = TCPSocket.new host, port

    begin
      connection = server.accept
      assert connection.scheduler == scheduler

    ensure
      connection.close
      server.close
      client.close
    end
  end

  context 'SSL' do
    server_context = Networking::Controls::SSL::Context::Server.example
    client_context = Networking::Controls::SSL::Context::Client.example

    test 'Accepting a connection' do
      client = Networking::Connection::Client.build host, port, :ssl => client_context
      server = Networking::Server.build port, :ssl_context => server_context

      output = nil

      server_thread = Thread.new do
        connection = server.accept
        output = connection.read
        connection.close
        server.close
      end

      client_thread = Thread.new do
        client.write data
        client.close
      end

      client_thread.join
      server_thread.join

      assert output == data
    end

    test 'Error During OpenSSL Handshaking' do
      next
      Connection::Controls::SSL.pair do |server, client|
        client.to_io.close
        connection = server.accept
        assert connection.nil?
      end
    end
  end
end
