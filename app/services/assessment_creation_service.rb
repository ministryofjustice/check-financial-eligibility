class AssessmentCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/assessment.json').to_s

  attr_reader :assessment_hash, :raw_post

  def initialize(remote_ip, raw_post)
    @raw_post = raw_post
    @assessment_hash = JSON.parse(raw_post).merge(remote_ip: remote_ip)
  end

  def success?
    errors.empty?
  end

  def assessment
    new_assessment if errors.empty?
  end

  def errors
    validator.valid? ? new_assessment.errors.full_messages : validator.errors
  end

  private

  def new_assessment
    @new_assessment ||= Assessment.create(assessment_hash)
  end

  def validator
    @validator ||= JsonSchemaValidator.new(raw_post, SCHEMA_PATH)
  end
end
