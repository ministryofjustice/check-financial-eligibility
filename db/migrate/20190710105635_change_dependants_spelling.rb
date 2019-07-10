class ChangeDependantsSpelling < ActiveRecord::Migration[5.2]
  def change
    rename_table :dependents, :dependants

    rename_table :dependent_income_receipts, :dependant_income_receipts
    rename_column :dependant_income_receipts, :dependent_id, :dependant_id
  end
end
