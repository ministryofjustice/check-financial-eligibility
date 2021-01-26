class AddBankCashTransactionsToGrossIncomeSummary < ActiveRecord::Migration[6.1]
  def change
    add_column :gross_income_summaries, :benefits_all_sources, :decimal, default: 0.0
    add_column :gross_income_summaries, :friends_or_family_all_sources, :decimal, default: 0.0
    add_column :gross_income_summaries, :maintenance_in_all_sources, :decimal, default: 0.0
    add_column :gross_income_summaries, :property_or_lodger_all_sources, :decimal, default: 0.0
    add_column :gross_income_summaries, :pension_all_sources, :decimal, default: 0.0

    add_column :gross_income_summaries, :benefits_bank, :decimal, default: 0.0
    add_column :gross_income_summaries, :friends_or_family_bank, :decimal, default: 0.0
    add_column :gross_income_summaries, :maintenance_in_bank, :decimal, default: 0.0
    add_column :gross_income_summaries, :property_or_lodger_bank, :decimal, default: 0.0
    add_column :gross_income_summaries, :pension_bank, :decimal, default: 0.0

    add_column :gross_income_summaries, :benefits_cash, :decimal, default: 0.0
    add_column :gross_income_summaries, :friends_or_family_cash, :decimal, default: 0.0
    add_column :gross_income_summaries, :maintenance_in_cash, :decimal, default: 0.0
    add_column :gross_income_summaries, :property_or_lodger_cash, :decimal, default: 0.0
    add_column :gross_income_summaries, :pension_cash, :decimal, default: 0.0
  end
end
