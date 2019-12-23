class CreateChildcareOutgoings < ActiveRecord::Migration[6.0]
  def change
    create_table :childcare_outgoings do |t|
      t.belongs_to :disposable_income_summaries, foreign_key: true, null: false, type: :uuid
      t.date :payment_date, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
