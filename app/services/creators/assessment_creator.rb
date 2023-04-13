module Creators
  class AssessmentCreator
    CreationResult = Struct.new :errors, :assessment, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(remote_ip:, assessment_params:, version:)
        assessment_hash =
          {
            client_reference_id: assessment_params[:client_reference_id],
            submission_date: Date.parse(assessment_params[:submission_date]),
            level_of_help: assessment_params[:level_of_help] || "certificated",
            version:,
            remote_ip:,
          }

        new_assessment = create_new_assessment_and_summary_records assessment_hash
        if new_assessment.valid?
          CreationResult.new(errors: [], assessment: new_assessment).freeze
        else
          CreationResult.new(errors: new_assessment.errors.full_messages).freeze
        end
      end

    private

      def create_new_assessment_and_summary_records(assessment_hash)
        Assessment.transaction do
          Assessment.new(assessment_hash).tap do |assessment|
            assessment.build_capital_summary
            assessment.build_gross_income_summary
            assessment.build_disposable_income_summary
            Creators::EligibilitiesCreator.call(assessment) if assessment.save
          end
        end
      end
    end
  end
end
