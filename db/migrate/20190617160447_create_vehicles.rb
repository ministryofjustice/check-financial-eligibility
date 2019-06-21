class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.decimal :value
      t.decimal :loan_amount_outstanding
      t.date :date_of_purchase
      t.boolean :in_regular_use

      t.timestamps
    end
  end
end
