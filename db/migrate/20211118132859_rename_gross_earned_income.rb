class RenameGrossEarnedIncome < ActiveRecord::Migration[6.1]
  def change
    rename_column :gross_income_summaries, :gross_earned_income, :gross_employment_income
    rename_column :disposable_income_summaries, :earned_income_deductions, :employment_income_deductions
  end
end
