class Connection
  attr_reader :io
  attr_reader :read_buffer_size
  attr_reader :socket

  dependency :logger, Telemetry::Logger
  dependency :scheduler, Scheduler

  def initialize(socket, io, read_buffer_size)
    @io = io
    @socket = socket
    @read_buffer_size = read_buffer_size
  end

  def self.build(socket, scheduler=nil)
    io =
      case socket
      when IO, StringIO then socket
      else socket.to_io
      end

    instance = new socket, io, default_read_buffer_size
    Telemetry::Logger.configure instance

    if scheduler
      instance.scheduler = scheduler
    else
      Scheduler.configure instance
    end

    instance
  end

  def close
    io.close
    socket.close unless socket.closed?
  end

  def closed?
    socket.closed?
  end

  def fileno
    Fileno.get io
  end

  def gets(separator_or_limit=$INPUT_RECORD_SEPARATOR, limit=nil)
    logger.opt_trace "Reading Line (Separator: #{separator_or_limit.inspect}, Bytes Requested: #{limit.inspect}, Fileno: #{fileno})"

    line = nil

    loop do
      character = socket.read_nonblock 1, :exception => false

      if character == :wait_readable
        logger.opt_debug "Deferring gets; read would block (Fileno: #{fileno})"
        scheduler.wait_readable io
        next
      elsif character.nil?
        break
      end

      socket.ungetc character

      if limit.nil?
        line = socket.gets separator_or_limit
      else
        line = socket.gets separator_or_limit, limit
      end
      break
    end

    if line
      logger.opt_debug "Read line (Separator: #{separator_or_limit.inspect}, Bytes Requested: #{limit.inspect}, Fileno: #{fileno}, Bytes: #{line.bytesize})"
      logger.opt_data line
    else
      logger.opt_debug "Did not dead line; EOF reached (Separator: #{separator_or_limit.inspect}, Bytes Requested: #{limit.inspect}, Fileno: #{fileno})"
    end

    line
  end

  def read(bytes=nil, outbuf=nil)
    outbuf ||= String.new
    outbuf.clear

    read_size = bytes || read_buffer_size

    logger.opt_trace "Reading (Bytes Requested: #{bytes}, Fileno: #{fileno})"

    loop do
      logger.opt_trace "Reading chunk (Max Size: #{read_size}, Fileno: #{fileno})"

      data = socket.read_nonblock read_size, nil, :exception => false

      case data
      when :wait_readable then
        logger.opt_debug "Deferring chunk; read would block (Read Size: #{read_size}, Fileno: #{fileno})"
        scheduler.wait_readable io
        next
      when nil then
        logger.opt_debug "Read finished (Bytes Requested: #{bytes}, Fileno: #{fileno}, Bytes Read: #{outbuf.bytesize})"
        break
      else
        logger.opt_debug "Finished reading chunk (Max Size: #{read_size}, Fileno: #{fileno}, Bytes Read: #{data.bytesize})"
        logger.opt_data data

        outbuf << data
      end

      break if outbuf.bytesize == bytes
    end

    outbuf
  end

  def readline(*arguments)
    result = gets *arguments
    raise EOFError if result.nil?
    result
  end

  def write(data)
    data = data.to_s

    logger.opt_trace "Writing (Bytes Requested: #{data.bytesize}, Fileno: #{fileno})"
    logger.opt_data data

    loop do
      bytes_written = socket.write_nonblock data, :exception => false

      if bytes_written == :wait_writable
        logger.opt_debug "Deferring write; write would block (Fileno: #{fileno})"
        scheduler.wait_writable io
        next
      end

      logger.opt_debug "Written (Bytes Requested: #{data.bytesize}, Fileno: #{fileno})"
      return bytes_written
    end
  end

  def self.default_read_buffer_size
    8192
  end

  def self.client(*arguments)
    logger = Telemetry::Logger.get self
    logger.obsolete "Use of Connection.client is deprecated; prefer Connection::Client.build"

    Connection::Client.build *arguments
  end

  def self.server(*arguments)
    logger = Telemetry::Logger.get self
    logger.obsolete "Use of Connection.server is deprecated; prefer Connection::Server.build"

    Connection::Server.build *arguments
  end
end
