module Calculators
  class MonthlyOtherIncomeCalculator
    attr_reader :assessment

    delegate :gross_income_summary, to: :assessment

    def self.call(assessment_id)
      new(assessment_id).call
    end

    def initialize(assessment_id)
      @assessment = Assessment.find assessment_id
    end

    def call
      total_monthly_income = 0
      gross_income_summary.other_income_sources.each do |source|
        total_monthly_income += source.calculate_monthly_income!
      end
      gross_income_summary.update!(monthly_other_income: total_monthly_income)
    end
  end
end
