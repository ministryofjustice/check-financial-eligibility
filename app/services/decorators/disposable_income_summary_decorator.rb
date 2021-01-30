module Decorators
  class DisposableIncomeSummaryDecorator
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def as_json
      return nil if record.nil?

      attrs = {}
      monthly_equivalents_key = assessment_v3? ? :monthly_equivalents : :monthly_outgoing_equivalents
      attrs[monthly_equivalents_key] = MonthlyOutgoingEquivalentDecorator.new(record).as_json

      attrs.update(default_attrs)
    end

    private

    def default_attrs # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        childcare_allowance: record.childcare,
        deductions: DeductionsDecorator.new(record).as_json,
        dependant_allowance: record.dependant_allowance,
        maintenance_allowance: record.maintenance,
        gross_housing_costs: record.gross_housing_costs,
        housing_benefit: record.housing_benefit,
        net_housing_costs: record.net_housing_costs,
        total_outgoings_and_allowances: record.total_outgoings_and_allowances,
        total_disposable_income: record.total_disposable_income,
        lower_threshold: record.lower_threshold,
        upper_threshold: record.upper_threshold,
        assessment_result: record.assessment_result,
        income_contribution: record.income_contribution
      }
    end

    def assessment_v3?
      record.version == CFEConstants::LATEST_ASSESSMENT_VERSION
    end
  end
end
