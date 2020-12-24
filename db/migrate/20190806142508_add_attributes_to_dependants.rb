class AddAttributesToDependants < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :dependants, :relationship, :string
    add_column :dependants, :monthly_income, :decimal
    add_column :dependants, :assets_value, :decimal
    # rubocop:enable Rails/BulkChangeTable
  end
end
