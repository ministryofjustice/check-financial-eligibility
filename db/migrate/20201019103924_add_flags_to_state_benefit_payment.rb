class AddFlagsToStateBenefitPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :state_benefit_payments, :flags, :json
  end
end
