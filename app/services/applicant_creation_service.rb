class ApplicantCreationService < BaseCreationService
  attr_accessor :raw_post, :applicant

  def initialize(raw_post)
    @raw_post = raw_post
  end

  def call
    validate_and_create
    self
  end

  private

  def validate_and_create
    create_applicant
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_applicant
    (raise CreationError, ['There is already an applicant for this assesssment']) if assessment.applicant.present?
    @applicant ||= assessment.create_applicant!(payload[:applicant])
  rescue ActiveRecord::RecordInvalid => e
    raise CreationError, e.record.errors.full_messages
  end

  def assessment
    @assessment ||= Assessment.find_by(id: payload[:assessment_id]) || (raise CreationError, ['No such assessment id'])
  end

  def payload
    @payload ||= JSON.parse(raw_post, symbolize_names: true)
  end
end
