module Decorators
  module V5
    class CapitalItemDecorator
      def initialize(record)
        @record = record
      end

      def as_json
        {
          description: @record.description,
          value: @record.value,
        }
      end
    end
  end
end
