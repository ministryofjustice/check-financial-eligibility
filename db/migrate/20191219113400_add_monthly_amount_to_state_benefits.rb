class AddMonthlyAmountToStateBenefits < ActiveRecord::Migration[6.0]
  def change
    add_column :state_benefits, :monthly_value, :decimal, default: 0.0, null: false
  end
end
