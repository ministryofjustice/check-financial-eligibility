module Creators
  class DisposableIncomeEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @summary = assessment.disposable_income_summary
    end

    def call
      @assessment.proceeding_types.map(&:ccms_code).each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      @summary.eligibilities.create!(
        proceeding_type_code: ptc,
        upper_threshold: upper_threshold(ptc),
        lower_threshold:,
        assessment_result: "pending",
      )
    end

    def lower_threshold
      Threshold.value_for(:disposable_income_lower, at: @assessment.submission_date)
    end

    def upper_threshold(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).disposable_income_upper_threshold
    end
  end
end
