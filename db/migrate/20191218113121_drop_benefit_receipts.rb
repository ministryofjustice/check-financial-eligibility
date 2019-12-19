class DropBenefitReceipts < ActiveRecord::Migration[6.0]
  def up
    drop_table :benefit_receipts
  end

  def down
    create_table :benefit_receipts do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.string :benefit_name
      t.date :payment_date
      t.decimal :amount

      t.timestamps
    end
  end
end
