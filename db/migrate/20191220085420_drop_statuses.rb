class DropStatuses < ActiveRecord::Migration[6.0]
  def up
    drop_table :statuses
  end

  def down
    create_table :statuses do |t|
      t.string :response

      t.timestamps
    end
  end
end
