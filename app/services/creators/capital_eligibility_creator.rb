module Creators
  class CapitalEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @summary = assessment.capital_summary
    end

    def call
      @assessment.proceeding_type_codes.each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      @summary.eligibilities.create!(
        proceeding_type_code: ptc,
        upper_threshold: upper_threshold(ptc),
        lower_threshold: lower_threshold(ptc),
        assessment_result: 'pending'
      )
    end

    def upper_threshold(ptc)
      ProceedingTypeThreshold.value_for(ptc.to_sym, :capital_upper, @assessment.submission_date)
    end

    def lower_threshold(ptc)
      ProceedingTypeThreshold.value_for(ptc.to_sym, :capital_lower, @assessment.submission_date)
    end
  end
end
