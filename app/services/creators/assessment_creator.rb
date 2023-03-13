module Creators
  class AssessmentCreator
    CreationResult = Struct.new :errors, :assessment, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(remote_ip:, assessment_params:, version:)
        new(remote_ip:, assessment_params:, version:).call
      end
    end

    def initialize(remote_ip:, assessment_params:, version:)
      super()
      @assessment_params = assessment_params
      @remote_ip = remote_ip
      @version = version
    end

    def call
      if json_validator.valid?
        new_assessment = create_new_assessment_and_summary_records
        if new_assessment.valid?
          CreationResult.new(errors: [], assessment: new_assessment).freeze
        else
          CreationResult.new(errors: new_assessment.errors.full_messages).freeze
        end
      else
        CreationResult.new(errors: json_validator.errors).freeze
      end
    end

  private

    def assessment_hash
      {
        client_reference_id: @assessment_params[:client_reference_id],
        submission_date: Date.parse(@assessment_params[:submission_date]),
        level_of_help: @assessment_params[:level_of_help] || "certificated",
        version: @version,
        remote_ip: @remote_ip,
      }
    end

    def create_new_assessment_and_summary_records
      Assessment.transaction do
        assessment = Assessment.new(assessment_hash)
        assessment.build_capital_summary
        assessment.build_gross_income_summary
        assessment.build_disposable_income_summary
        Creators::EligibilitiesCreator.call(assessment) if assessment.save

        assessment
      end
    end

    def json_validator
      @json_validator ||= JsonValidator.new("assessment", @assessment_params)
    end
  end
end
