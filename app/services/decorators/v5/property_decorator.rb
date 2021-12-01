module Decorators
  module V5
    class PropertyDecorator
      def initialize(property)
        @record = property
      end

      def as_json
        payload unless @record.nil?
      end

      private

      def payload # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          value: @record.value.to_f,
          outstanding_mortgage: @record.outstanding_mortgage.to_f,
          percentage_owned: @record.percentage_owned.to_f,
          main_home: @record.main_home,
          shared_with_housing_assoc: @record.shared_with_housing_assoc,
          transaction_allowance: @record.transaction_allowance.to_f,
          allowable_outstanding_mortgage: @record.allowable_outstanding_mortgage.to_f,
          net_value: @record.net_value.to_f,
          net_equity: @record.net_equity.to_f,
          main_home_equity_disregard: @record.main_home_equity_disregard.to_f,
          assessed_equity: @record.assessed_equity.to_f
        }
      end
    end
  end
end
