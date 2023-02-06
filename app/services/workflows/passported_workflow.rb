module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment)
        capital_subtotals = CapitalCollatorAndAssessor.call assessment
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
