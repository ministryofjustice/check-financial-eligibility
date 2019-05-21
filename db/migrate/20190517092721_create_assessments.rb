class CreateAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :assessments, id: :uuid do |t|
      t.string :client_reference_id
      t.inet :remote_ip, null: false
      t.json :request_payload, null: false
      t.json :response_payload
      t.string :result
      t.timestamps
    end
    add_index :assessments, :client_reference_id, unique: false
  end
end
