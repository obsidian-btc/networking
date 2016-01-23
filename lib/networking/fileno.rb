module Networking
  module Fileno
    def self.get(io)
      case io
      when StringIO then '<stringio>'
      else io.fileno
      end
    end
  end
end
