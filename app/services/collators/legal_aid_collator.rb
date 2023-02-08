module Collators
  class LegalAidCollator
    class << self
      def call(disposable_income_summary)
        legal_aid_bank = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.legal_aid_outgoings,
        )

        # TODO: return this instead of persisting it
        disposable_income_summary.update!(legal_aid_bank:)
      end
    end
  end
end
