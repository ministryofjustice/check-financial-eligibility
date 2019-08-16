class AddIndividualFieldsToResult < ActiveRecord::Migration[5.2]
  def change
    remove_column :results, :details, :jsonb
    add_column :results, :liquid_capital, :decimal, default: 0.0
    add_column :results, :property, :decimal, default: 0.0
    add_column :results, :vehicles, :decimal, default: 0.0
    add_column :results, :non_liquid_capital, :decimal, default: 0.0
    add_column :results, :single_capital_assessment, :decimal, default: 0.0
    add_column :results, :pensioner_disregard, :decimal, default: 0.0
    add_column :results, :disposable_capital, :decimal, default: 0.0
    add_column :results, :total_capital_lower_threshold, :decimal, default: 0.0
    add_column :results, :total_capital_upper_threshold, :decimal, default: 0.0
  end
end
