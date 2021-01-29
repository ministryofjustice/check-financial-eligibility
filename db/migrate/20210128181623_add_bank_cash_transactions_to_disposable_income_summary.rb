class AddBankCashTransactionsToDisposableIncomeSummary < ActiveRecord::Migration[6.1]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.decimal :child_care_all_sources, default: 0.0
      t.decimal :maintenance_out_all_sources, default: 0.0
      t.decimal :rent_or_mortgage_all_sources, default: 0.0
      t.decimal :legal_aid_all_sources, default: 0.0

      t.decimal :child_care_bank, default: 0.0
      t.decimal :maintenance_out_bank, default: 0.0
      t.decimal :rent_or_mortgage_bank, default: 0.0
      t.decimal :legal_aid_bank, default: 0.0

      t.decimal :child_care_cash, default: 0.0
      t.decimal :maintenance_out_cash, default: 0.0
      t.decimal :rent_or_mortgage_cash, default: 0.0
      t.decimal :legal_aid_cash, default: 0.0
    end
  end
end
