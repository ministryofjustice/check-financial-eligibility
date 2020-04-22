module Decorators
  class DisposableIncomeSummaryDecorator
    attr_reader :assessment

    def initialize(record)
      @record = record
    end

    def as_json # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil if @record.nil?

      {
        monthly_outgoing_equivalents: MonthlyOutgoingEquivalentDecorator.new(@record).as_json,
        childcare_allowance: @record.childcare,
        dependant_allowance: @record.dependant_allowance,
        maintenance_allowance: @record.maintenance,
        gross_housing_costs: @record.gross_housing_costs,
        housing_benefit: @record.housing_benefit,
        net_housing_costs: @record.net_housing_costs,
        total_outgoings_and_allowances: @record.total_outgoings_and_allowances,
        total_disposable_income: @record.total_disposable_income,
        lower_threshold: @record.lower_threshold,
        upper_threshold: @record.upper_threshold,
        assessment_result: @record.assessment_result,
        income_contribution: @record.income_contribution
      }
    end
  end
end
