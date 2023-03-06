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
      @assessment.proceeding_types.map(&:ccms_code).each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      return if eligibility_record_exists?(ptc)

      if @assessment.level_of_help == "controlled"
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: controlled_threshold(ptc),
          lower_threshold: controlled_threshold(ptc),
        )
      elsif ptc.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: immigration_threshold,
          lower_threshold: immigration_threshold,
        )
      elsif ptc.to_sym == CFEConstants::ASYLUM_PROCEEDING_TYPE_CCMS_CODE
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: asylum_threshold,
          lower_threshold: asylum_threshold,
        )
      else
        @summary.eligibilities.create!(
          proceeding_type_code: ptc,
          upper_threshold: upper_threshold(ptc),
          lower_threshold:,
        )
      end
    end

    def immigration_threshold
      Threshold.value_for(:capital_immigration_upper_tribunal_certificated, at: @assessment.submission_date)
    end

    def asylum_threshold
      Threshold.value_for(:capital_asylum_upper_tribunal_certificated, at: @assessment.submission_date)
    end

    def controlled_threshold(ptc)
      if ptc.to_sym == CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE
        Threshold.value_for(:capital_immigration_first_tier_tribunal_controlled, at: @assessment.submission_date)
      else
        upper_threshold(ptc)
      end
    end

    def lower_threshold
      Threshold.value_for(:capital_lower_certificated, at: @assessment.submission_date)
    end

    def upper_threshold(ptc)
      @assessment.proceeding_types.find_by!(ccms_code: ptc).capital_upper_threshold
    end

    def eligibility_record_exists?(ptc)
      @summary.eligibilities.where(proceeding_type_code: ptc).any?
    end
  end
end
