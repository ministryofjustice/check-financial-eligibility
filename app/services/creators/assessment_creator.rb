module Creators
  class AssessmentCreator < BaseCreator
    SCHEMA_PATH = Rails.root.join('public/schemas/assessment.json').to_s

    attr_reader :assessment_hash, :raw_post

    def initialize(remote_ip, raw_post)
      @raw_post = raw_post
      @assessment_hash = JSON.parse(raw_post).merge(remote_ip: remote_ip)
    end

    def call
      self
    end

    def as_json(_options = nil)
      {
        success: success?,
        objects: ([new_assessment] if success?),
        errors: errors
      }
    end

    def errors
      new_assessment.errors.full_messages
    end

    private

    def new_assessment
      @new_assessment ||= begin
        new_assessment = Assessment.new(assessment_hash)
        new_assessment.create_capital_summary! if new_assessment.save
        new_assessment.create_gross_income_summary! if new_assessment.save
        new_assessment
      end
    end
  end
end
