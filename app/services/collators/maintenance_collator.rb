module Collators
  class MaintenanceCollator < BaseWorkflowService
    def call
      disposable_income_summary.calculate_monthly_maintenance_amount!
    end
  end
end
