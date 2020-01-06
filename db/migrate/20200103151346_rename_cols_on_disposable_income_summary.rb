class RenameColsOnDisposableIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    rename_column :disposable_income_summaries, :monthly_childcare, :childcare
    rename_column :disposable_income_summaries, :monthly_dependant_allowance, :dependant_allowance
    rename_column :disposable_income_summaries, :monthly_maintenance, :maintenance
    rename_column :disposable_income_summaries, :monthly_gross_housing_costs, :gross_housing_costs
    rename_column :disposable_income_summaries, :total_monthly_outgoings, :total_outgoings_and_allowances
    rename_column :disposable_income_summaries, :monthly_net_housing_costs, :net_housing_costs
    rename_column :disposable_income_summaries, :monthly_housing_benefit, :housing_benefit
  end
end
