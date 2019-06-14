class ApplicantCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/applicant.json').to_s

  def initialize(raw_post)
    @raw_post = raw_post
    @payload = JSON.parse(raw_post, symbolize_names: true)
  end

  def success?
    errors.empty?
  end

  def errors
    validator.valid? ? new_applicant.errors.full_messages : validator.errors
  end

  def assessment
    @assessment ||= Assessment.find(@payload[:assessment_id])
  end

  private

  def new_applicant
    @new_applicant ||= assessment.create_applicant(@payload[:applicant])
  end

  def validator
    @validator = JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
  end
end
