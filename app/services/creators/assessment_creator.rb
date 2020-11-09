module Creators
  class AssessmentCreator < BaseCreator
    SCHEMA_PATH = Rails.root.join('public/schemas/assessment.json').to_s

    attr_reader :assessment_hash, :raw_post

    def initialize(remote_ip:, raw_post:)
      super()
      @raw_post = raw_post
      @assessment_hash = JSON.parse(raw_post).merge(remote_ip: remote_ip)
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
