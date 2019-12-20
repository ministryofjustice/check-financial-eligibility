class AddCodeToStateBenefitTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :state_benefit_types, :dwp_code, :string, null: true

    add_index :state_benefit_types, :dwp_code, unique: true
    add_index :state_benefit_types, :label, unique: true
  end
end
