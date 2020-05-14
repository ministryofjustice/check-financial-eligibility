class AddClientIdToIncomeOutoging < ActiveRecord::Migration[6.0]
  def change
    add_column :state_benefit_payments, :client_id, :string, default: nil
    add_column :other_income_payments, :client_id, :string, default: nil
    add_column :outgoings, :client_id, :string, default: nil
  end
end
