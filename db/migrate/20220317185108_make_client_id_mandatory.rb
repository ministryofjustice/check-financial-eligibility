class MakeClientIdMandatory < ActiveRecord::Migration[7.0]
  def up
    Employment.where(client_id: nil).update_all(client_id: "not-specified")
    EmploymentPayment.where(client_id: nil).update_all(client_id: "not-specified")
    change_column :employment_payments, :client_id, :string, null: false
    change_column :employments, :client_id, :string, null: false
  end

  def down
    Employment.where(client_id: "not-specified").update_all(client_id: nil)
    EmploymentPayment.where(client_id: "not-specified").update_all(client_id: nil)
    change_column :employment_payments, :client_id, :string, null: true
    change_column :employments, :client_id, :string, null: true
  end
end
