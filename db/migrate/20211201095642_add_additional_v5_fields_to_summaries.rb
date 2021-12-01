class AddAdditionalV5FieldsToSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :gross_income_summaries, :monthly_benefits_in_kind, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :taxes, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :ni_contributions, :decimal, null: false, default: 0.0
  end
end
