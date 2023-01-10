class AddCombinedContributionsToSummaries < ActiveRecord::Migration[7.0]
  def change
    add_column :capital_summaries, :combined_capital_contribution, :decimal
  end
end
