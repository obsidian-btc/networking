module Networking
  module Fileno
    def self.get(io)
      io.fileno
    end
  end
end
