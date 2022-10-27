class AddUnspecifiedSourceIncomeToGrossIncomeSummaries < ActiveRecord::Migration[7.0]
  def change
    change_table :gross_income_summaries, bulk: true do |t|
      t.decimal "unspecified_source", default: "0.0"
      t.decimal "monthly_unspecified_source"
    end
  end
end
