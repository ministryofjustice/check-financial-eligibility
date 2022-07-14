class AddAdjustedIncomeToGrossIncomeSummary < ActiveRecord::Migration[7.0]
  def change
    add_column :gross_income_summaries, :adjusted_income, :decimal, default: 0.0
  end
end
