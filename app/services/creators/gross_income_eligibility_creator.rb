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
      # TODO: remove if statement once version 4 deprecated
      if @assessment.version_5?
        @assessment.proceeding_types.map(&:ccms_code).each { |ptc| create_eligibility(ptc) }
      else
        @assessment.proceeding_type_codes.each { |ptc| create_eligibility(ptc) }
      end
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
      base_threshold = @assessment.version_5? ? threshold_from_proceeding_type(ptc) : threshold_from_service(ptc)

      return base_threshold if base_threshold == 999_999_999_999

      base_threshold + dependant_increase
    end

    def threshold_from_proceeding_type(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).gross_income_upper_threshold
    end

    def threshold_from_service(ptc)
      ProceedingTypeThreshold.value_for(ptc.to_sym, :gross_income_upper, @assessment.submission_date)
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
