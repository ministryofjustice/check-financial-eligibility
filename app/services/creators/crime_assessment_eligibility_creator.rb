module Creators
  class CrimeAssessmentEligibilityCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      @assessment.create_crime_eligibility!(assessment_result: "pending")
    end
  end
end
