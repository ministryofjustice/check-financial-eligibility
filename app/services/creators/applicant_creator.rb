module Creators
  class ApplicantCreator < BaseCreator
    attr_accessor :assessment_id, :applicant

    def initialize(assessment_id:, applicant_params:)
      super()
      @assessment_id = assessment_id
      @applicant_params = applicant_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        self.errors = json_validator.errors
      end
      self
    end

  private

    def create_records
      create_applicant
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_applicant
      (raise CreationError, ["No such assessment id"]) if assessment.nil?
      (raise CreationError, ["There is already an applicant for this assesssment"]) if assessment.applicant.present?
      self.applicant = assessment.create_applicant!(applicant_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id)
    end

    def applicant_attributes
      @applicant_attributes ||= JSON.parse(@applicant_params, symbolize_names: true)[:applicant]
    end

    def json_validator
      @json_validator ||= assessment&.version == "5" ? JsonValidator.new("applicant_v5", @applicant_params) : JsonValidator.new("applicant", @applicant_params)
    end
  end
end
