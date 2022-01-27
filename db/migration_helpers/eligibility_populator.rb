module MigrationHelpers
  class EligibilityPopulator
    def self.call
      new.call
    end

    def initialize
      @klasses = [GrossIncomeSummary, DisposableIncomeSummary, CapitalSummary]
      @assessment_ids = Assessment.pluck(:id)
    end

    def call
      @klasses.each { |klass| populate_eligibility(klass) }
    end

  private

    def populate_eligibility(klass)
      @assessment_ids.each { |assessment_id| populate_eligibility_for_assessment(klass, assessment_id) }
    end

    def populate_eligibility_for_assessment(klass, assessment_id)
      assessment = Assessment.find(assessment_id)
      summary = klass.find_by(assessment_id:)
      return if summary.nil?
      return if summary.assessment_result == 'migrated_to_eligibility'

      return unless summary.eligibilities.empty?

      assessment.proceeding_type_codes.each { |ptc| create_eligibility(summary, ptc) }
    end

    def create_eligibility(summary, ptc)
      ActiveRecord::Base.transaction do
        summary.eligibilities.create!(proceeding_type_code: ptc,
                                      lower_threshold: summary.has_attribute?(:lower_threshold) ? summary.lower_threshold : nil,
                                      upper_threshold: summary.upper_threshold,
                                      assessment_result: summary.assessment_result || 'pending')
        summary.update!(assessment_result: 'migrated_to_eligibility')
      end
    end
  end
end
