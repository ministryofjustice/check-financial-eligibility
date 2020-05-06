require_relative '../migration_helpers/category_seeder'

class SeedStateBenefitCategories < ActiveRecord::Migration[6.0]
  def up
    MigrationHelpers::CategorySeeder.call
  end

  def down
    # no-op
  end
end
