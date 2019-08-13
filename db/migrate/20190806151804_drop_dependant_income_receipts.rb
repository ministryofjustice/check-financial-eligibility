class DropDependantIncomeReceipts < ActiveRecord::Migration[5.2]
  def change
    drop_table :dependant_income_receipts, id: :uuid do |t|
      t.uuid :dependant_id
      t.date :date_of_payment
      t.decimal :amount

      t.timestamps
    end
  end
end
