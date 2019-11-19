class CreateWagePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :wage_payments, id: :uuid do |t|
      t.references :employment, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.decimal :gross_payment, null: false
      t.timestamps
    end
  end
end
