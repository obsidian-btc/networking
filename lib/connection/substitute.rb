class Connection
  class Substitute
    dependency :logger, Telemetry::Logger

    attr_writer :closed

    def self.build
      instance = new
      Telemetry::Logger.configure instance
      instance
    end

    def close
      self.closed = true
    end

    def closed
      @closed ||= false
    end

    def closed?
      if closed then true else false end
    end

    def current_expectation
      expectations.fetch 0 do
        Expectation::None.instance
      end
    end

    def gets(*arguments)
      readline *arguments
    rescue EOFError
      return nil
    end

    def eof
      expectation = Expectation::EOF
      expectations << expectation
    end

    def expect_read(data)
      expectation = Expectation::Read.build data
      expectations << expectation
    end

    def expect_write(data)
      expectation = Expectation::Write.build data
      expectations << expectation
    end

    def expectations
      @expectations ||= []
    end

    def fileno
      Fileno.get self
    end

    def read(*arguments)
      output = current_expectation.read *arguments
      expectations.shift if current_expectation.eof?
      output
    end

    def readline(*arguments)
      output = current_expectation.readline *arguments
      expectations.shift if current_expectation.eof?
      output
    end

    def write(*arguments)
      output = current_expectation.write *arguments
      current_expectation.verify_written
      expectations.shift if current_expectation.finished?
      output
    end
  end
end
