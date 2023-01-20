module Creators
  class AssessmentCreator < BaseCreator
    SCHEMA_PATH = Rails.root.join("public/schemas/assessment.json").to_s

    def initialize(remote_ip:, assessment_params:, version:)
      super()
      @assessment_params = assessment_params
      @remote_ip = remote_ip
      @parsed_raw_post = JSON.parse(assessment_params, symbolize_names: true)
      @version = version
    end

    def call
      self
    end

    def as_json(_options = nil)
      {
        success: success?,
        assessment_id: new_assessment.id,
        errors:,
      }
    end

    def errors
      new_assessment_errors.concat(json_validator.errors)
    end

  private

    def new_assessment_errors
      new_assessment&.errors&.full_messages || []
    end

    def generate_assessment_hash(remote_ip)
      {
        client_reference_id: @parsed_raw_post[:client_reference_id],
        submission_date: Date.parse(@parsed_raw_post[:submission_date]),
        version: @version,
        remote_ip:,
      }.merge(@parsed_raw_post.slice(:level_of_representation))
    end

    def new_assessment
      @new_assessment ||= create_new_assessment_and_summary_records if json_validator.valid?
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

    def assessment_hash
      generate_assessment_hash(@remote_ip)
    end

    def json_validator
      @json_validator ||= JsonValidator.new("assessment", @assessment_params)
    end
  end
end
