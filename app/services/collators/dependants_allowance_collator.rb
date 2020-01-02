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
      if assessment.dependants.any?
        disposable_income_summary.update!(monthly_dependant_allowance: assessment.dependants.sum(&:dependant_allowance))
      end
    end
  end
end
