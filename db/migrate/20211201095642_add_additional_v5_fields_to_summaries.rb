class AddAdditionalV5FieldsToSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :gross_income_summaries, :benefits_in_kind, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :tax, :decimal, null: false, default: 0.0
    add_column :disposable_income_summaries, :national_insurance, :decimal, null: false, default: 0.0
  end
end
