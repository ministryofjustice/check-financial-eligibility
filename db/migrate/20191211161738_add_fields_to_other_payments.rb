class AddFieldsToOtherPayments < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :other_income_sources, :monthly_income, :decimal
    add_column :other_income_sources, :assessment_error, :boolean, default: false
    # rubocop:enable Rails/BulkChangeTable
  end
end
