class CreateBankHolidays < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_holidays, id: :uuid do |t|
      t.text :dates

      t.timestamps
    end
  end
end
