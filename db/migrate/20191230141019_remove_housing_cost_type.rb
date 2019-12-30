class RemoveHousingCostType < ActiveRecord::Migration[6.0]
  def change
    remove_column :disposable_income_summaries, :housing_cost_type, :string
  end
end
