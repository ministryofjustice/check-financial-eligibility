module Collators
  class OutgoingsCollator < BaseWorkflowService
    def call
      collate_costs_and_allowances
    end

  private

    def collate_costs_and_allowances
      Collators::ChildcareCollator.call(assessment)
      Collators::DependantsAllowanceCollator.call(assessment)
      Collators::MaintenanceCollator.call(assessment)
      Collators::HousingCostsCollator.call(assessment)
      Collators::LegalAidCollator.call(assessment)
    end
  end
end
