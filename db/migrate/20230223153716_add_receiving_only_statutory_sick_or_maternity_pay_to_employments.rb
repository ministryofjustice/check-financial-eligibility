class AddReceivingOnlyStatutorySickOrMaternityPayToEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :employments, :receiving_only_statutory_sick_or_maternity_pay, :boolean, default: false
  end
end
