class CreateRequestsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :request_logs, id: :uuid do |t|
      t.string :request_method
      t.string :endpoint
      t.string :assessment_id
      t.string :params
      t.integer :http_status
      t.string :response
      t.decimal :duration
      t.timestamps
    end
  end
end
