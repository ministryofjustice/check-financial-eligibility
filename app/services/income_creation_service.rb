class IncomeCreationService < BaseCreationService
  attr_reader :assessment_id, :benefits_attributes, :wage_slips_attributes

  def initialize(assessment_id:, benefits_attributes:, wage_slips_attributes:)
    @assessment_id = assessment_id
    @benefits_attributes = benefits_attributes
    @wage_slips_attributes = wage_slips_attributes
  end

  def call
    build_objects && self
  end

  def as_json(_options = nil)
    {
      success: success?,
      wage_slips: (wage_slips if success?),
      benefits: (benefit_receipts if success?),
      errors: errors
    }
  end

  def build_objects
    WageSlip.transaction do
      wage_slips
      benefit_receipts
    end
  end

  def wage_slips
    @wage_slips ||= wage_slips_attributes.map do |attributes|
      assessment.wage_slips.create(attributes)
    end
  end

  def benefit_receipts
    @benefit_receipts ||= benefits_attributes.map do |attributes|
      assessment.benefit_receipts.create(attributes)
    end
  end

  def errors
    @errors ||= (wage_slips + benefit_receipts).map { |model| model.errors.full_messages }.flatten.compact
  end

  def assessment
    @assessment ||= Assessment.find(assessment_id)
  end
end
