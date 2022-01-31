class CreateIrregularIncomePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :irregular_income_payments, id: :uuid do |t|
      t.belongs_to :gross_income_summary, foreign_key: true, null: false, type: :uuid
      t.string :income_type, null: false
      t.string :frequency, null: false
      t.decimal :amount, default: false

      t.timestamps
    end
    add_index :irregular_income_payments, %i[gross_income_summary_id income_type], unique: true, name: "irregular_income_payments_unique"
  end
end
