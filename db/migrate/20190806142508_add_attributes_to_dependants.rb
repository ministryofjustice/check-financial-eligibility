class AddAttributesToDependants < ActiveRecord::Migration[5.2]
  def change
    add_column :dependants, :relationship, :string
    add_column :dependants, :monthly_income, :decimal
    add_column :dependants, :assets_value, :decimal
  end
end
