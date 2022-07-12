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
        lower_threshold:,
        assessment_result: "pending",
      )
    end

    def lower_threshold
      Threshold.value_for(:disposable_income_lower, at: @assessment.submission_date)
    end

    # TODO: once version 4 is deprecated, then remove code to get threshold from service and just copy from proceeding type record
    #
    def upper_threshold(ptc)
      @assessment.version_5? ? threshold_from_proceeding_type(ptc) : threshold_from_service(ptc)
    end

    def threshold_from_service(ptc)
      ProceedingTypeThreshold.value_for(ptc.to_sym, :disposable_income_upper, @assessment.submission_date)
    end

    def threshold_from_proceeding_type(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).disposable_income_upper_threshold
    end
  end
end
