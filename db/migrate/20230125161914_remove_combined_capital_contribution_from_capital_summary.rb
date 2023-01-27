class RemoveCombinedCapitalContributionFromCapitalSummary < ActiveRecord::Migration[7.0]
  def change
    remove_column :capital_summaries, :combined_capital_contribution, :decimal
  end
end
