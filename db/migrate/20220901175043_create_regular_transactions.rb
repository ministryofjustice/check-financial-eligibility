class CreateRegularTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :regular_transactions, id: :uuid do |t|
      t.belongs_to :gross_income_summary, foreign_key: true, null: false, type: :uuid
      t.string :category
      t.string :operation
      t.decimal :amount
      t.string :frequency
      t.timestamps
    end
  end
end
