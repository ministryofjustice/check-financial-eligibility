class CreateCashTransactionCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :cash_transaction_categories, id: :uuid do |t|
      t.references :gross_income_summary, foreign_key: true, type: :uuid
      t.string :operation
      t.string :name

      t.timestamps
    end

    add_index :cash_transaction_categories,
              %i[gross_income_summary_id name operation],
              name: 'index_cash_transaction_categories_uniqueness',
              unique: true
  end
end
