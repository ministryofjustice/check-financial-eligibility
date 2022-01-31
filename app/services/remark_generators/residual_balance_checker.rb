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
      current_accounts = assessment.capital_items.where(description: "Current accounts")
      highest_current_account_balance = current_accounts.map(&:value).max || 0
      capital_exceeds_lower_threshold? && highest_current_account_balance.positive?
    end

    def capital_exceeds_lower_threshold?
      assessment.capital_summary.assessed_capital > lower_capital_threshold
    end

    def populate_remarks
      my_remarks = assessment.remarks
      my_remarks.add(:current_account_balance, :residual_balance, [])
      assessment.update!(remarks: my_remarks)
    end

    def lower_capital_threshold
      # we can take the lower threshold from the first eligibility records as they are all the same
      assessment.capital_summary.eligibilities.first.lower_threshold
    end

    attr_reader :assessment
  end
end
