module Decorators
  module V5
    class DeductionsDecorator
      def initialize(disposable_income_summary, dependant_allowance:)
        @record = disposable_income_summary
        @dependant_allowance = dependant_allowance
      end

      def as_json
        {
          dependants_allowance: @dependant_allowance,
          disregarded_state_benefits: Calculators::DisregardedStateBenefitsCalculator.call(@record),
        }
      end
    end
  end
end
