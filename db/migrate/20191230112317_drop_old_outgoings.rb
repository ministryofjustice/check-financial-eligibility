class DropOldOutgoings < ActiveRecord::Migration[6.0]
  def up
    drop_table :outgoings
  end

  def down
    create_table :outgoings, id: :uuid do |t|
      t.string :outgoing_type
      t.date :payment_date
      t.decimal :amount
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.timestamps
    end
  end
end
