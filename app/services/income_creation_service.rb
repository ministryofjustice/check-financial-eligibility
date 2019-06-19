class IncomeCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/income.json').to_s

  def self.call(raw_post)
    service = new(raw_post)
    service.call
  end

  def initialize(raw_post)
    @raw_post = raw_post
    @payload = JSON.parse(@raw_post, symbolize_names: true)
    @errors = []
  end

  def call
    if json_valid? && assessment_exists?
      return success_response if create_income_records
    end
    error_response
  end

  private

  def json_valid?
    validator = JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
    return true if validator.valid?

    @errors = validator.errors
    false
  end

  def assessment_exists?
    @assessment = Assessment.find_by(id: @payload[:assessment_id])
    return true unless @assessment.nil?

    @errors << 'No such assessment id'
    false
  end

  def create_income_records
    new_wage_slips
    new_benefit_receipts
    return true if @assessment.save

    collect_model_errors
    false
  end

  def new_wage_slips
    @payload[:income][:wage_slips]&.each do |slip|
      @assessment.wage_slips.new(slip)
    end
  end

  def new_benefit_receipts
    @payload[:income][:benefits]&.each do |benefit_params|
      @assessment.benefit_receipts.new(benefit_params)
    end
  end

  def collect_model_errors
    @errors = @assessment.wage_slips.map { |ws| ws.errors.full_messages } +
              @assessment.benefit_receipts.map { |br| br.errors.full_messages }
    @errors.flatten!
  end

  def success_response
    ApiResponse.success(@assessment.wage_slips + @assessment.benefit_receipts)
  end

  def error_response
    ApiResponse.error(@errors)
  end
end
