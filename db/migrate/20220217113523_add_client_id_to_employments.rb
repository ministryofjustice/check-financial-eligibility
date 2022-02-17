class AddClientIdToEmployments < ActiveRecord::Migration[6.1]
  def change
    add_column :employments, :client_id, :string
    add_column :employment_payments, :client_id, :string
  end
end
