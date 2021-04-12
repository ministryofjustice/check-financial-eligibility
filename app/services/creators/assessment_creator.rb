module Creators
  class AssessmentCreator < BaseCreator
    SCHEMA_PATH = Rails.root.join('public/schemas/assessment.json').to_s

    attr_reader :assessment_hash, :raw_post

    def initialize(remote_ip:, raw_post:, version:)
      super()
      parsed_raw_post = JSON.parse(raw_post, symbolize_names: true)
      @assessment_hash = {
        client_reference_id: parsed_raw_post[:client_reference_id],
        submission_date: Date.parse(parsed_raw_post[:submission_date]),
        matter_proceeding_type: parsed_raw_post[:matter_proceeding_type],
        proceeding_type_codes: ccms_codes_from_post(parsed_raw_post),
        version: version,
        remote_ip: remote_ip
      }
    end

    def call
      self
    end

    def as_json(_options = nil)
      {
        success: success?,
        assessment_id: new_assessment.id,
        errors: errors
      }
    end

    def errors
      new_assessment.errors.full_messages
    end

    private

    def ccms_codes_from_post(post)
      return nil unless post.key?(:proceeding_types)

      post[:proceeding_types][:ccms_codes]
    end

    def new_assessment
      @new_assessment ||= create_new_assessment_and_summary_records
    end

    def create_new_assessment_and_summary_records
      Assessment.transaction do
        assessment_record = Assessment.new(assessment_hash)
        assessment_record.build_capital_summary
        assessment_record.build_gross_income_summary
        assessment_record.build_disposable_income_summary
        assessment_record.save
        assessment_record
      end
    end
  end
end
