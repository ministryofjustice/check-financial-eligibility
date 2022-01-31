class AddTypeToUniqueIndex < ActiveRecord::Migration[6.1]
  def up
    remove_index :eligibilities, name: "index_eligibilities_on_parent_id_and_proceeding_type_code"
    add_index :eligibilities, %i[parent_id type proceeding_type_code], name: "eligibilities_unique_type_ptc", unique: true
  end

  def down
    remove_index :eligibilities, name: "eligibilities_unique_type_ptc"
    add_index :eligibilities, %i[parent_id proceeding_type_code], name: "index_eligibilities_on_parent_id_and_proceeding_type_code", unique: true
  end
end
