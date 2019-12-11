class AddFieldsToOtherPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :other_income_sources, :monthly_income, :decimal
    add_column :other_income_sources, :assessment_error, :boolean, default: false
  end
end
