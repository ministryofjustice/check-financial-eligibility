module Calculators
  class StateBenefitsCalculator
    class << self
      def call(state_benefits)
        total_monthly_state_benefits state_benefits
      end

    private

      def total_monthly_state_benefits(state_benefits)
        total = 0.0

        state_benefits.each do |state_benefit|
          monthly_value = Calculators::MonthlyEquivalentCalculator.call(
            assessment_errors: state_benefit.gross_income_summary.assessment.assessment_errors,
            collection: state_benefit.state_benefit_payments,
          )
          # TODO: Stop persisting this
          state_benefit.update!(monthly_value:)

          total += monthly_value unless state_benefit.exclude_from_gross_income
        end
        total
      end
    end
  end
end
