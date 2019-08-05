class ApplicantCreationService < BaseCreationService
  attr_accessor :assessment_id, :applicant_attributes, :applicant

  def initialize(assessment_id:, applicant_attributes:)
    @assessment_id = assessment_id
    @applicant_attributes = applicant_attributes
  end

  def call
    create
    self
  end

  private

  def create
    create_applicant
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_applicant
    (raise CreationError, ['There is already an applicant for this assesssment']) if assessment.applicant.present?
    self.applicant = assessment.create_applicant!(applicant_attributes)
  rescue ActiveRecord::RecordInvalid => e
    raise CreationError, e.record.errors.full_messages
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end
end
