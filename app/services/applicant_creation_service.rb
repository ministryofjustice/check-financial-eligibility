class ApplicantCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/applicant.json').to_s

  def initialize(raw_post)
    @raw_post = raw_post
    @payload = JSON.parse(raw_post, symbolize_names: true)
    @errors = nil
  end

  def success?
    errors.empty?
  end

  def errors
    @errors ||= validator.valid? ? applicant_errors : validator.errors
  end

  def assessment
    @assessment ||= Assessment.find_by(id: @payload[:assessment_id])
    @errors = ['No such assessment ID'] if @assessment.nil?
    @assessment
  end

  private

  def applicant_errors
    assessment.nil? ? @errors : new_applicant.errors.full_messages
  end

  def new_applicant
    @new_applicant ||= assessment.create_applicant(@payload[:applicant])
  end

  def validator
    @validator = JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
  end
end
