module MigrationHelpers
  class ProceedingTypeCodeSeeder
    def self.call
      new.call
    end

    def call
      assessments = Assessment.where(version: "3")
      assessments.each do |rec|
        next unless rec.proceeding_type_codes.empty?

        rec.update!(proceeding_type_codes: ["DA001"])
      end
    end
  end
end
