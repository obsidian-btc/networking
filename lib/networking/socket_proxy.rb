module Networking
  class SocketProxy
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

    def fileno
      Fileno.get io
    end

    def read(bytes=nil, outbuf=nil)
      outbuf ||= String.new
      outbuf.clear

      read_size = bytes || read_buffer_size

      logger.trace "Reading (Bytes Requested: #{bytes.inspect}, Fileno: #{fileno})"

      loop do
        logger.trace "Reading chunk (Max Size: #{read_size}, Fileno: #{fileno})"

        data = socket.read_nonblock read_size, nil, :exception => false

        case data
        when :wait_readable then
          logger.debug "Deferring chunk; read would block (Read Size: #{read_size}, Fileno: #{fileno})"
          scheduler.wait_readable io
          next
        when nil then
          logger.debug "Read finished (Bytes Requested: #{bytes.inspect}, Fileno: #{fileno}, Bytes Read: #{outbuf.bytesize})"
          break
        else
          logger.debug "Finished reading chunk (Max Size: #{read_size}, Fileno: #{fileno}, Bytes Read: #{data.bytesize})"
          logger.data data

          outbuf << data
        end

        break if outbuf.bytesize == bytes
      end

      outbuf
    end

    def self.default_read_buffer_size
      8192
    end

    module Assertions
      def reads_scheduled(io=nil)
        scheduler.sink.records.select do |record|
          next unless record.signal == :read_scheduled

          if io
            record.data == io
          else
            true
          end
        end
      end
    end
  end
end
