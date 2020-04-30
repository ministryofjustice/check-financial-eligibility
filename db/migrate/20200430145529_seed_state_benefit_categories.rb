require_relative '../migration_helpers/category_seeder'

class SeedStateBenefitCategories < ActiveRecord::Migration[6.0]
  def up
    MigrationHelpers::CategorySeeder.call
    execute "UPDATE state_benefit_types SET CATEGORY = 'uncategorised' WHERE category IS NULL AND exclude_from_gross_income = 't'"
  end

  def down
    execute 'UPDATE state_benefit_types SET category = NULL'
  end
end
