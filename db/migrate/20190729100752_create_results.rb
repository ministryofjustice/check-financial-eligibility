class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.uuid :assessment_id
      t.jsonb :result_hash
    end
  end
end
