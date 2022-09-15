module Decorators
  module V5
    class DeductionsDecorator
      def initialize(disposable_income_summary)
        @record = disposable_income_summary
      end

      def as_json
        {
          dependants_allowance: @record.dependant_allowance,
          disregarded_state_benefits: Calculators::DisregardedStateBenefitsCalculator.call(@record),
        }
      end
    end
  end
end
