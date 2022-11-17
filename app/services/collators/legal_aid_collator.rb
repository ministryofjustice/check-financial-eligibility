module Collators
  class LegalAidCollator
    class << self
      def call(disposable_income_summary)
        disposable_income_summary.calculate_monthly_legal_aid_amount!
      end
    end
  end
end
