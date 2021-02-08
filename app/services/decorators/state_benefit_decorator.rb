module Decorators
  class StateBenefitDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(record, state_benefit)
      @record = record
      @state_benefit = state_benefit
      @categories = %i[benefits]
    end

    def as_json
      record.v3? ? payload_v3 : payload_v2
    end

    private

    def payload_v2
      {
        name: @state_benefit.state_benefit_name,
        monthly_value: @state_benefit.monthly_value,
        excluded_from_income_assessment: @state_benefit.exclude_from_gross_income,
        state_benefit_payments: payments
      }
    end

    def payload_v3
      {
        name: @state_benefit.state_benefit_name,
        all_sources: all_benefit_transactions[:all_sources][:benefits],
        cash_transactions: all_benefit_transactions[:cash_transactions][:benefits],
        bank_transactions: @state_benefit.monthly_value,
        excluded_from_income_assessment: @state_benefit.exclude_from_gross_income
      }
    end

    def all_benefit_transactions
      @all_benefit_transactions ||= all_transaction_types
    end

    def payments
      @state_benefit.state_benefit_payments.map do |payment|
        PaymentDecorator.new(payment).as_json
      end
    end
  end
end
