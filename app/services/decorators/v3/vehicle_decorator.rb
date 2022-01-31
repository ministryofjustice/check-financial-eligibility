module Decorators
  module V3
    class VehicleDecorator
      def initialize(record)
        @record = record
      end

      def as_json
        {
          value: @record.value,
          loan_amount_outstanding: @record.loan_amount_outstanding,
          date_of_purchase: @record.date_of_purchase,
          in_regular_use: @record.in_regular_use,
          included_in_assessment: @record.included_in_assessment,
          assessed_value: @record.assessed_value,
        }
      end
    end
  end
end
