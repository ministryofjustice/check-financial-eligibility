module Collators
  class LegalAidCollator < BaseWorkflowService
    def call
      disposable_income_summary.calculate_monthly_legal_aid_amount!
    end
  end
end
