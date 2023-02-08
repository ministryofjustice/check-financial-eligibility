module Collators
  class MaintenanceCollator
    class << self
      def call(disposable_income_summary)
        maintenance_out_bank = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.maintenance_outgoings,
        )

        # TODO: return this value instead of persisting it
        disposable_income_summary.update!(maintenance_out_bank:)
      end
    end
  end
end
