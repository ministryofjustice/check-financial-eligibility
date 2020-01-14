module Decorators
  class DisposableIncomeSummaryDecorator
    attr_reader :assessment

    def initialize(record)
      @record = record
    end

    def as_json # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil if @record.nil?

      {
        outgoings: {
          childcare_costs: @record.childcare_outgoings.map { |co| PaymentDecorator.new(co).as_json },
          housing_costs: @record.housing_cost_outgoings.map { |hc| PaymentDecorator.new(hc).as_json },
          maintenance_costs: @record.maintenance_outgoings.map { |mo| PaymentDecorator.new(mo).as_json }
        },
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
