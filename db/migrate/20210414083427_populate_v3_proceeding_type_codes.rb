class PopulateV3ProceedingTypeCodes < ActiveRecord::Migration[6.1]
  def up
    # The two lines below have been commented out since they are no longer needed.
    # The original ProceedingTypeCodeSeeder just populated the proceeding_type_codes on every record with [DA001]
    # and was used int he v2 to V3 migration
    # require Rails.root.join("db/migration_helpers/proceeding_type_code_seeder")
    # MigrationHelpers::ProceedingTypeCodeSeeder.call
  end

  def down
    Assessment.all.each do |assessment|
      next unless assessment.version == "3" && assessment.proceeding_type_codes == %w[DA001]

      assessment.update!(proceeding_type_codes: [])
    end
  end
end
