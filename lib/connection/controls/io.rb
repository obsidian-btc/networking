class Connection
  module Controls
    module IO
      module Octet
        def self.example
          "\x00"
        end
      end

      module Reading
        def self.example(data=nil)
          data ||= Data.example
          StringIO.new data
        end
      end

      module Writing
        def self.example
          StringIO.new
        end
      end

      module Timeout
        def self.example
          10
        end

        def self.short
          Rational(1, 1000)
        end
      end
    end
  end
end
