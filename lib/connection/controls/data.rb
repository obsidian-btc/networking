class Connection
  module Controls
    module Data
      def self.example
        'some-data'
      end

      module PlainText
        module MultipleLines
          def self.example(separator = nil)
            separator ||= $INPUT_RECORD_SEPARATOR

            first_line = SingleLine.example separator

            "#{first_line}Another line of text#{separator}"
          end
        end

        module SingleLine
          def self.example(separator = nil)
            separator ||= $INPUT_RECORD_SEPARATOR
            "Some line of text#{separator}"
          end
        end
      end
    end
  end
end
