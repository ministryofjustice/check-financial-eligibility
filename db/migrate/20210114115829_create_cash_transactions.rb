class CreateCashTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :cash_transactions, id: :uuid do |t|
      t.references :cash_transaction_category, foreign_key: true, type: :uuid
      t.date :date
      t.decimal :amount
      t.string :client_id

      t.timestamps
    end
  end
end
