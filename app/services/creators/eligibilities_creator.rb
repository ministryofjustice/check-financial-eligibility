module Creators
  class EligibilitiesCreator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      if @assessment.criminal?
        AdjustedIncomeEligibilityCreator.call(@assessment)
        CrimeAssessmentEligibilityCreator.call(@assessment)
      else
        GrossIncomeEligibilityCreator.call(@assessment)
        DisposableIncomeEligibilityCreator.call(@assessment)
        CapitalEligibilityCreator.call(@assessment)
        AssessmentEligibilityCreator.call(@assessment)
      end
    end
  end
end
