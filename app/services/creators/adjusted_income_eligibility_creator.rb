module Creators
    class AdjustedIncomeEligibilityCreator
      def self.call(assessment)
        new(assessment).call
      end
  
      def initialize(assessment)
        @assessment = assessment
        @summary = @assessment.gross_income_summary
      end
  
      def call
        @summary.crime_eligibilities.create!(
            upper_threshold: Threshold.value_for(:adjusted_income_upper),
            lower_threshold: Threshold.value_for(:adjusted_income_lower),
            assessment_result: "pending",
        )
      end
  end
end