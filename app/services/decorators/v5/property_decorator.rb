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

      def payload
        {
          value: @record.value,
          outstanding_mortgage: @record.outstanding_mortgage,
          percentage_owned: @record.percentage_owned,
          main_home: @record.main_home,
          shared_with_housing_assoc: @record.shared_with_housing_assoc,
          transaction_allowance: @record.transaction_allowance,
          allowable_outstanding_mortgage: @record.outstanding_mortgage,
          net_value: @record.net_value,
          net_equity: @record.net_equity,
          smod_allowance: @record.smod_allowance,
          main_home_equity_disregard: @record.main_home_equity_disregard,
          assessed_equity: @record.assessed_equity,
        }
      end
    end
  end
end
