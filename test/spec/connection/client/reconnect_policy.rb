require_relative './client_spec_init'

context 'Client Connection' do
  context 'Never reconnect policy' do
    policy = Networking::Connection::Client::ReconnectPolicy::Never.new

    test 'Indicates a closed connection should not be reconnected' do
      io = StringIO.new
      io.close

      assert !policy.reconnect?(io)
    end

    test 'Indicates an open connection should not be reconnected' do
      io = StringIO.new

      assert !policy.reconnect?(io)
    end
  end

  context 'When Closed reconnect policy' do
    policy = Networking::Connection::Client::ReconnectPolicy::WhenClosed.new

    test 'Indicates a closed connection should be reconnected' do
      io = StringIO.new
      io.close

      assert policy.reconnect?(io)
    end

    test 'Indicates an open connection should not be reconnected' do
      io = StringIO.new

      assert !policy.reconnect?(io)
    end
  end

  context 'Resolving a reconnect policy' do
    test 'Exists' do
      policy = Networking::Connection::Client::ReconnectPolicy.get :never

      assert policy.is_a?(Networking::Connection::Client::ReconnectPolicy)
    end

    test 'Does not exist' do
      begin
        Networking::Connection::Client::ReconnectPolicy.get :not_a_policy
      rescue Networking::Connection::Client::ReconnectPolicy::Error => error
      end

      assert error
    end
  end
end
