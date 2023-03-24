module Collators
  class LegalAidCollator
    class << self
      def call(disposable_income_summary)
        Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.legal_aid_outgoings,
        )
      end
    end
  end
end
