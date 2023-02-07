class RemoveColumnsFromCapitalSummaries < ActiveRecord::Migration[7.0]
  def change
    change_table :capital_summaries, bulk: true do |t|
      t.remove(:assessed_capital,
               :assessment_result,
               :capital_contribution,
               :total_capital,
               :total_liquid,
               :total_mortgage_allowance,
               :total_non_liquid, type: :decimal, null: false, default: 0)
    end
  end
end
