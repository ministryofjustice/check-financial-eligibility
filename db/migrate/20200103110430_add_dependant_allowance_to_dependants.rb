class AddDependantAllowanceToDependants < ActiveRecord::Migration[6.0]
  def change
    add_column :dependants, :dependant_allowance, :decimal, default: 0.0
  end
end
