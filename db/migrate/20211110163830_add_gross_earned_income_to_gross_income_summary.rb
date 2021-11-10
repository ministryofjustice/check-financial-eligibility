class AddGrossEarnedIncomeToGrossIncomeSummary < ActiveRecord::Migration[6.1]
  def change
    add_column :gross_income_summaries, :gross_earned_income, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :earned_income_deductions, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :fixed_employment_allowance, :decimal, null: false, default: 0.0
  end
end
