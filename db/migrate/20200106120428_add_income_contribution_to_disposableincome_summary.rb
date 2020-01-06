class AddIncomeContributionToDisposableincomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :disposable_income_summaries, :income_contribution, :decimal, default: 0.0
  end
end
