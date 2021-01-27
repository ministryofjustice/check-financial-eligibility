class AddBankCashTransactionsToGrossIncomeSummary < ActiveRecord::Migration[6.1]
  def change
    change_table :gross_income_summaries, bulk: true do |t|
      t.decimal :benefits_all_sources, default: 0.0
      t.decimal :friends_or_family_all_sources, default: 0.0
      t.decimal :maintenance_in_all_sources, default: 0.0
      t.decimal :property_or_lodger_all_sources, default: 0.0
      t.decimal :pension_all_sources, default: 0.0

      t.decimal :benefits_bank, default: 0.0
      t.decimal :friends_or_family_bank, default: 0.0
      t.decimal :maintenance_in_bank, default: 0.0
      t.decimal :property_or_lodger_bank, default: 0.0
      t.decimal :pension_bank, default: 0.0

      t.decimal :benefits_cash, default: 0.0
      t.decimal :friends_or_family_cash, default: 0.0
      t.decimal :maintenance_in_cash, default: 0.0
      t.decimal :property_or_lodger_cash, default: 0.0
      t.decimal :pension_cash, default: 0.0
    end
  end
end
