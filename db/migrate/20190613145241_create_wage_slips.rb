class CreateWageSlips < ActiveRecord::Migration[5.2]
  def change
    create_table :wage_slips do |t|
      t.uuid :assessment_id
      t.date :payment_date
      t.decimal :gross_pay
      t.decimal :paye
      t.decimal :nic

      t.timestamps
    end
  end
end
