class CreateOutgoings < ActiveRecord::Migration[5.2]
  def change
    create_table :outgoings, id: :uuid do |t|
      t.string :outgoing_type
      t.date :payment_date
      t.decimal :amount
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.timestamps
    end
  end
end
