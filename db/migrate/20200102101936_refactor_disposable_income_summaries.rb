class RefactorDisposableIncomeSummaries < ActiveRecord::Migration[6.0]
  def change
    rename_column :disposable_income_summaries, :monthly_housing_costs, :monthly_gross_housing_costs
    add_column :disposable_income_summaries, :monthly_net_housing_costs, :decimal, default: 0.0
    add_column :disposable_income_summaries, :monthly_housing_benefit, :decimal, default: 0.0
  end
end
