class AddFieldsToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :friends_or_family, :decimal, default: 0.0
    add_column :gross_income_summaries, :maintenance_in, :decimal, default: 0.0
    add_column :gross_income_summaries, :property_or_lodger, :decimal, default: 0.0
    add_column :gross_income_summaries, :student_loan, :decimal, default: 0.0
    add_column :gross_income_summaries, :pension, :decimal, default: 0.0
  end
end
