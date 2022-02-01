module Decorators
  module V4
    class CapitalItemDecorator
      def initialize(record)
        @record = record
      end

      def as_json
        {
          description: @record.description,
          value: @record.value.to_f,
        }
      end
    end
  end
end
