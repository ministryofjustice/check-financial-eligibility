module Collators
  class DependantsAllowanceCollator < BaseWorkflowService
    def call
      assessment.dependants.each do |dependant|
        dependant.update!(dependant_allowance: Calculators::DependantAllowanceCalculator.call(dependant))
      end
      collate!
    end

  private

    def collate!
      disposable_income_summary.update!(dependant_allowance: assessment.dependants.sum(&:dependant_allowance)) if assessment.dependants.any?
    end
  end
end
