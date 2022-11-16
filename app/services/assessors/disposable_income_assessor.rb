module Assessors
  class DisposableIncomeAssessor
    class << self
      def call(total_disposable_income:, disposable_income_summary:)
        new(total_disposable_income:, disposable_income_summary:).call
      end
    end

    def initialize(total_disposable_income:, disposable_income_summary:)
      @total_disposable_income = total_disposable_income
      @disposable_income_summary = disposable_income_summary
    end

    def call
      ActiveRecord::Base.transaction do
        update_eligibility_records
        @disposable_income_summary.update!(income_contribution:)
      end
    end

  private

    def update_eligibility_records
      @disposable_income_summary.eligibilities.each do |elig|
        elig.update!(assessment_result: assessment_result(elig))
      end
    end

    def assessment_result(elig)
      if @total_disposable_income <= elig.lower_threshold
        "eligible"
      elsif @total_disposable_income <= elig.upper_threshold
        "contribution_required"
      else
        "ineligible"
      end
    end

    def income_contribution
      contribution_required? ? calculate_contribution : 0.0
    end

    def calculate_contribution
      Calculators::IncomeContributionCalculator.call(@total_disposable_income)
    end

    def contribution_required?
      @disposable_income_summary.eligibilities.map(&:assessment_result).include?("contribution_required")
    end
  end
end
