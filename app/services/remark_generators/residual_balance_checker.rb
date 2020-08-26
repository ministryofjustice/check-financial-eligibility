module RemarkGenerators
  class ResidualBalanceChecker
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      populate_remarks if residual_balance?
    end

    private

    def residual_balance?
      current_accounts = assessment.capital_items.where(description: 'Current accounts')
      highest_current_account_balance = current_accounts.map(&:value).max || 0
      capital_exceeds_lower_threshold? && highest_current_account_balance.positive?
    end

    def capital_exceeds_lower_threshold?
      assessment.capital_summary.assessed_capital > assessment.capital_summary.lower_threshold
    end

    def populate_remarks
      my_remarks = assessment.remarks
      my_remarks.add(:current_account_balance, :residual_balance, [])
      assessment.update!(remarks: my_remarks)
    end

    attr_reader :assessment
  end
end
