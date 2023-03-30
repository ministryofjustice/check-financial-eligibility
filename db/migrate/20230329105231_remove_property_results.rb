class RemovePropertyResults < ActiveRecord::Migration[7.0]
  def change
    change_table :properties, bulk: true do |t|
      t.remove :transaction_allowance, :net_value, :net_equity, :main_home_equity_disregard,
               type: :decimal, default: 0, null: false
      t.remove :assessed_equity,
               type: :decimal
    end
  end
end
