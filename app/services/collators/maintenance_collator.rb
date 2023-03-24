module Collators
  class MaintenanceCollator
    class << self
      def call(disposable_income_summary)
        Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.maintenance_outgoings,
        )
      end
    end
  end
end
