module Decorators
  class PropertyDecorator
    attr_reader :assessment

    def initialize(record)
      @record = record
    end

    def as_json # rubocop:disable Metrics/MethodLength
      return nil if @record.nil?

      {
        value: @record.value,
        outstanding_mortgage: @record.outstanding_mortgage,
        percentage_owned: @record.percentage_owned,
        main_home: @record.main_home,
        shared_with_housing_assoc: @record.shared_with_housing_assoc,
        transaction_allowance: @record.transaction_allowance,
        allowable_outstanding_mortgage: @record.allowable_outstanding_mortgage,
        net_value: @record.net_value,
        net_equity: @record.net_equity,
        main_home_equity_disregard: @record.main_home_equity_disregard,
        assessed_equity: @record.assessed_equity
      }
    end
  end
end
