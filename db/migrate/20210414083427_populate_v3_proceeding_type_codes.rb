class PopulateV3ProceedingTypeCodes < ActiveRecord::Migration[6.1]
  def up
    require Rails.root.join('db/migration_helpers/proceeding_type_code_seeder')
    MigrationHelpers::ProceedingTypeCodeSeeder.call
  end

  def down
    Assessment.all.each do |assessment|
      next unless assessment.version == '3' && assessment.proceeding_type_codes == ['DA001']

      assessment.update!(proceeding_type_codes: [])
    end
  end
end
