class AddUpperThresholdToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :upper_threshold, :decimal, default: 0.0, null: false
  end
end
