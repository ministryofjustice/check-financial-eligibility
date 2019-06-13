class CreateDependentIncomeReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :dependent_income_receipts, id: :uuid do |t|
      t.uuid :dependent_id
      t.date :date_of_payment
      t.decimal :amount

      t.timestamps
    end
  end
end
