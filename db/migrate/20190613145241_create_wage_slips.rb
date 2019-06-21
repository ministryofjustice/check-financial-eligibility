class CreateWageSlips < ActiveRecord::Migration[5.2]
  def change
    create_table :wage_slips do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.date :payment_date
      t.decimal :gross_pay
      t.decimal :paye
      t.decimal :nic

      t.timestamps
    end
  end
end
