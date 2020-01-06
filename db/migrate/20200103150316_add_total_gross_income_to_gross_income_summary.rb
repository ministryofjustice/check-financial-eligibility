class AddTotalGrossIncomeToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :total_gross_income, :decimal, default: 0.0
  end
end
