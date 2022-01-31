module Creators
  class AssessmentEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      @assessment.proceeding_type_codes.each { |ptc| create_eligibility(ptc) }
    end

  private

    def create_eligibility(ptc)
      @assessment.eligibilities.create!(proceeding_type_code: ptc, assessment_result: "pending")
    end
  end
end
