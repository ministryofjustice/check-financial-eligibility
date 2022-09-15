module Creators
  class GrossIncomeEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
      @summary = assessment.gross_income_summary
    end

    def call
      @assessment.proceeding_types.map(&:ccms_code).each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      @summary.eligibilities.create!(
        proceeding_type_code: ptc,
        upper_threshold: upper_threshold(ptc),
        assessment_result: "pending",
      )
    end

    def upper_threshold(ptc)
      base_threshold = threshold_from_proceeding_type(ptc)

      return base_threshold if base_threshold == 999_999_999_999

      base_threshold + dependant_increase
    end

    def threshold_from_proceeding_type(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).gross_income_upper_threshold
    end

    def dependant_increase
      return 0 unless number_of_child_dependants > dependant_increase_starts_after

      (number_of_child_dependants - dependant_increase_starts_after) * dependant_step
    end

    def number_of_child_dependants
      @assessment.dependants.where(relationship: "child_relative").count
    end

    def dependant_increase_starts_after
      Threshold.value_for(:dependant_increase_starts_after, at: @assessment.submission_date)
    end

    def dependant_step
      Threshold.value_for(:dependant_step, at: @assessment.submission_date)
    end
  end
end
