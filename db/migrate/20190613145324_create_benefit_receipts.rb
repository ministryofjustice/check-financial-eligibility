class CreateBenefitReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :benefit_receipts do |t|
      t.uuid :assessment_id
      t.string :benefit_name
      t.date :payment_date
      t.decimal :amount

      t.timestamps
    end
  end
end
