class CreateOtherIncomePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :other_income_payments, id: :uuid do |t|
      t.belongs_to :other_income_source, foreign_key: true, null: false, type: :uuid
      t.date :payment_date, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
