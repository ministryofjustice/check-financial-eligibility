module Decorators
  class DisposableIncomeSummaryDecorator
    include Transactions

    attr_reader :record, :categories

    def initialize(disposable_income_summary)
      @record = disposable_income_summary
      @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
    end

    def as_json
      payload unless record.nil?
    end

    private

    def payload # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        monthly_equivalents: all_transaction_types,
        childcare_allowance: record.child_care_all_sources,
        deductions: DeductionsDecorator.new(record).as_json,
        dependant_allowance: record.dependant_allowance,
        maintenance_allowance: record.maintenance_out_all_sources,
        gross_housing_costs: record.gross_housing_costs,
        housing_benefit: record.housing_benefit,
        net_housing_costs: record.net_housing_costs,
        total_outgoings_and_allowances: record.total_outgoings_and_allowances,
        total_disposable_income: record.total_disposable_income,
        lower_threshold: record.eligibilities.first.lower_threshold,
        upper_threshold: record.eligibilities.first.upper_threshold,
        assessment_result: record.summarized_assessment_result,
        income_contribution: record.income_contribution
      }
    end
  end
end
