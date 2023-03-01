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
      if ptc.to_sym.in? CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: immigration_and_asylum_certificated_threshold,
          lower_threshold: immigration_and_asylum_certificated_threshold,
          assessment_result: "pending",
        )
      else
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: upper_threshold(ptc),
          lower_threshold:,
          assessment_result: "pending",
        )
      end
    end

    def immigration_and_asylum_certificated_threshold
      Threshold.value_for(:disposable_income_certificated_immigration_asylum_upper_tribunal, at: @assessment.submission_date)
    end

    def lower_threshold
      if @assessment.level_of_representation == "controlled"
        Threshold.value_for(:disposable_income_lower_controlled, at: @assessment.submission_date)
      else
        Threshold.value_for(:disposable_income_lower_certificated, at: @assessment.submission_date)
      end
    end

    def upper_threshold(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).disposable_income_upper_threshold
    end
  end
end
