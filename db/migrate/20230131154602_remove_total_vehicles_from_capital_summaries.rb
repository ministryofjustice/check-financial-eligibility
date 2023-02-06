class RemoveTotalVehiclesFromCapitalSummaries < ActiveRecord::Migration[7.0]
  def change
    remove_column :capital_summaries, :total_vehicle, :decimal, null: false, default: 0
  end
end
