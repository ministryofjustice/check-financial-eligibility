module Collators
  class OutgoingsCollator < BaseWorkflowService
    def call
      collate_costs_and_allowances
      Calculators::DisposableIncomeCalculator.call(assessment)
    end

    private

    def collate_costs_and_allowances
      Collators::ChildcareCollator.call(assessment)
      Collators::DependantsAllowanceCollator.call(assessment)
      Collators::MaintenanceCollator.call(assessment)
      Collators::HousingCostsCollator.call(assessment)
    end
  end
end
