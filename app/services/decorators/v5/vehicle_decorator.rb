module Decorators
  module V5
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
          disregards_and_deductions: @record.value.to_f - @record.assessed_value.to_f - @record.loan_amount_outstanding.to_f,
          assessed_value: @record.assessed_value.to_f,
        }
      end
    end
  end
end
