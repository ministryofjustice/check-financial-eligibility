module Decorators
  module V4
    class VehicleDecorator
      def initialize(record)
        @record = record
      end

      def as_json
        {
          value: @record.value.to_f,
          loan_amount_outstanding: @record.loan_amount_outstanding.to_f,
          date_of_purchase: @record.date_of_purchase,
          in_regular_use: @record.in_regular_use,
          included_in_assessment: @record.included_in_assessment,
          assessed_value: @record.assessed_value.to_f
        }
      end
    end
  end
end
