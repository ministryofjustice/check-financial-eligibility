class ChangeStateBenefitTypeName < ActiveRecord::Migration[6.0]
  def change
    rename_column :state_benefit_types, :description, :name
  end
end
