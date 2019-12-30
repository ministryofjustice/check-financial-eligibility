class CreateNewOutgoings < ActiveRecord::Migration[6.0]
  def up
    create_table :outgoings do |t|
      t.belongs_to :disposable_income_summary, foreign_key: true, null: false, type: :uuid
      t.string :type, null: false
      t.date :payment_date, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end

  def down
    drop_table :outgoings
  end
end
