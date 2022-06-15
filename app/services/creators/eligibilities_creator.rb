module Creators
  class EligibilitiesCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      if @assessment.assessment_type == "criminal"
        AdjustedIncomeEligibilityCreator.call(@assessment)
      else
        GrossIncomeEligibilityCreator.call(@assessment)
        DisposableIncomeEligibilityCreator.call(@assessment)
        CapitalEligibilityCreator.call(@assessment)
        AssessmentEligibilityCreator.call(@assessment)
      end
    end
  end
end
