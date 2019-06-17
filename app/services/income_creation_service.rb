class IncomeCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/income.json').to_s

  attr_reader :http_status

  def initialize(raw_post)
    @raw_post = raw_post
    @payload = JSON.parse(@raw_post, symbolize_names: true)
    @errors = []
  end

  def success?
    errors.empty?
  end

  def assessment
    @assessment ||= Assessment.find_by_id(@payload[:assessment_id])
  end

  def errors
    validator.valid? ? model_errors : validator.errors
  end

  private

  def validator
    @validator ||= JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
  end

  def model_errors
    @model_errors ||= create_income_records
  end

  def create_income_records
    if assessment.nil?
      @errors << 'No such assessment id'
    else
      create_wage_slips
      create_benefit_receipts
    end
    @errors.flatten
  end

  def create_wage_slips
    @payload[:income][:wage_slips]&.each do |slip|
      create_wage_slip(slip)
    end
  end

  def create_wage_slip(params)
    wage_slip = @assessment.wage_slips.new(params)
    wage_slip.save
    @errors << wage_slip.errors.full_messages
  end

  def create_benefit_receipts
    @payload[:income][:benefits]&.each do |benefit_params|
      create_benefit(benefit_params)
    end
  end

  def create_benefit(params)
    benefit = @assessment.benefit_receipts.new(params)
    benefit.save
    @errors << benefit.errors.full_messages
  end
end
