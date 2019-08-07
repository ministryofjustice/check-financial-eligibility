class DependantsCreationService < BaseCreationService
  attr_accessor :assessment_id, :dependants_attributes, :dependants

  def initialize(assessment_id:, dependants_attributes:)
    @assessment_id = assessment_id
    @dependants_attributes = dependants_attributes
  end

  def call
    create
    self
  end

  private

  def create
    create_dependants
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_dependants
    self.dependants = assessment.dependants.create!(dependant_params)
  rescue ActiveRecord::RecordInvalid => e
    raise CreationError, e.record.errors.full_messages
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end

  def dependant_params
    dependants_attributes.map do |dependant|
      dependant[:dependant_income_receipts_attributes] = dependant.delete(:income) if dependant[:income]
      dependant
    end
  end
end
