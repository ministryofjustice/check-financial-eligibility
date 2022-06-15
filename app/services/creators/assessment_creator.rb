module Creators
  class AssessmentCreator < BaseCreator
    SCHEMA_PATH = Rails.root.join("public/schemas/assessment.json").to_s

    attr_reader :assessment_hash, :raw_post

    def initialize(remote_ip:, raw_post:, version:)
      super()
      @parsed_raw_post = JSON.parse(raw_post, symbolize_names: true)
      @version = version
      @assessment_hash = generate_assessment_hash(remote_ip)
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
      new_assessment.errors.full_messages
    end

  private

    def generate_assessment_hash(remote_ip)
      {
        client_reference_id: @parsed_raw_post[:client_reference_id],
        submission_date: Date.parse(@parsed_raw_post[:submission_date]),
        matter_proceeding_type: @parsed_raw_post[:matter_proceeding_type],
        proceeding_type_codes: ccms_codes_for_application,
        assessment_type:,
        version: @version,
        remote_ip:,
      }
    end

    def assessment_type
      @parsed_raw_post[:assessment_type]
    end

    def ccms_codes_for_application
      @version == "3" || assessment_type == "criminal" ? dummy_code_for_domestic_abuse : codes_from_post
    end

    # For version 3, which are all single_proceeding type (domestic abuse),
    # we just create an assessment with one dummy domestic abuse proceeding type.
    # This allows us to treat both versions the same for determining thresholds.
    #
    def dummy_code_for_domestic_abuse
      %w[DA001]
    end

    def codes_from_post
      @parsed_raw_post[:proceeding_types][:ccms_codes]
    end

    def new_assessment
      @new_assessment ||= create_new_assessment_and_summary_records
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
  end
end
