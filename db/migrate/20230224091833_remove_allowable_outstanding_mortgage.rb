class RemoveAllowableOutstandingMortgage < ActiveRecord::Migration[7.0]
  def change
    remove_column :properties, :allowable_outstanding_mortgage, :decimal, default: "0.0", null: false
  end
end
