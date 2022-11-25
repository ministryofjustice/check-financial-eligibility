module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment)
        CapitalCollatorAndAssessor.call assessment
      end
    end
  end
end
