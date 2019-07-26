class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.uuid :assessment_id
      t.string :state
      t.jsonb :details
      t.timestamps
    end
  end
end
