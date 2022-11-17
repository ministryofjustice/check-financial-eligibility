module Collators
  class MaintenanceCollator
    class << self
      def call(disposable_income_summary)
        disposable_income_summary.calculate_monthly_maintenance_amount!
      end
    end
  end
end
