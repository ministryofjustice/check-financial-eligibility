class IncomeCreationService < BaseCreationService
  attr_reader :assessment_id, :benefit_attributes, :wage_slip_attributes

  def initialize(assessment_id:, benefits:, wage_slips:)
    @assessment_id = assessment_id
    @benefit_attributes = benefits
    @wage_slip_attributes = wage_slips
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
    @wage_slips ||= wage_slip_attributes.map do |attributes|
      assessment.wage_slips.create(attributes)
    end
  end

  def benefit_receipts
    @benefit_receipts ||= benefit_attributes.map do |attributes|
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
