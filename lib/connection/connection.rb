module Connection
  def self.client(*arguments)
    logger.obsolete "Use of Connection.client is deprecated; prefer Connection::Client.build"

    Connection::Client.build *arguments
  end

  def self.server(*arguments)
    logger.obsolete "Use of Connection.server is deprecated; prefer Connection::Server.build"

    Connection::Server.build *arguments
  end

  def self.logger
    @logger ||= Telemetry::Logger.get self
  end
end
