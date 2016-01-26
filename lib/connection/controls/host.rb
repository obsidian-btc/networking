class Connection
  module Controls
    module Host
      def self.example
        'example.com'
      end

      module Localhost
        def self.example
          '127.0.0.1'
        end
      end
    end
  end
end
