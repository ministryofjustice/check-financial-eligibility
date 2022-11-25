class AddCombinedTotalGrossIncomeToGrossIncomeSummary < ActiveRecord::Migration[7.0]
  def change
    add_column :gross_income_summaries, :combined_total_gross_income, :decimal
    change_table :disposable_income_summaries, bulk: true do |t|
      t.decimal :combined_total_disposable_income
      t.decimal :combined_total_outgoings_and_allowances
    end
    add_column :capital_summaries, :combined_assessed_capital, :decimal
  end
end
