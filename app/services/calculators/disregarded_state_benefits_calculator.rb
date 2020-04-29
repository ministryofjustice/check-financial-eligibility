module Calculators
  class DisregardedStateBenefitsCalculator
    attr_reader :disposable_income_summary

    delegate :assessment, to: :disposable_income_summary
    delegate :gross_income_summary, to: :assessment
    delegate :state_benefits, to: :gross_income_summary

    def self.call(disposable_income_summary)
      new(disposable_income_summary).call
    end

    def initialize(disposable_income_summary)
      @disposable_income_summary = disposable_income_summary
    end

    def call
      result = 0.0
      state_benefits.each do |state_benefit|
        result += state_benefit.monthly_value if state_benefit.exclude_from_gross_income?
      end
      result
    end
  end
end
