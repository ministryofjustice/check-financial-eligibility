class CreateStateBenefitPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :state_benefit_payments do |t|
      t.belongs_to :state_benefit, foreign_key: true, null: false, type: :uuid
      t.date :payment_date, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
