class AddVersionProceedingTypeCodes < ActiveRecord::Migration[6.1]
  # rubocop:disable Rails/BulkChangeTable
  def up
    add_column :assessments, :version, :string
    add_column :assessments, :proceeding_type_codes, :string
    change_column :assessments, :matter_proceeding_type, :string, null: true

    execute 'UPDATE assessments SET version = 3'
  end

  def down
    remove_column :assessments, :version
    remove_column :assessments, :proceeding_type_codes
    change_column :assessments, :matter_proceeding_type, :string, null: false
  end
  # rubocop:enable Rails/BulkChangeTable
end
