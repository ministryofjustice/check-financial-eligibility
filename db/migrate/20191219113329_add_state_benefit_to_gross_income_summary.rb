class AddStateBenefitToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :monthly_state_benefits, :decimal, default: 0.0, null: false
  end
end
