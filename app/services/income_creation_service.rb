class IncomeCreationService
  include Rails.application.routes.url_helpers

  SCHEMA_PATH = Rails.root.join('public/schemas/income.json').to_s

  attr_reader :http_status

  def initialize(raw_payload)
    @raw_payload = raw_payload
    @payload = JSON.parse(@raw_payload, symbolize_names: true)
    @errors = []
  end

  def result_payload
    if json_payload_valid? && create_incomes
      @http_status = 200
      success_response
    else
      @http_status = 422
      error_response
    end
  end

  private

  def json_payload_valid?
    validator = JsonSchemaValidator.new(@raw_payload, SCHEMA_PATH)
    if validator.invalid?
      @errors = validator.errors
      return false
    end
    true
  end

  def create_incomes
    @result = :ok
    @assessment = Assessment.find_by_id(@payload[:assessment_id])
    if @assessment.nil?
      @errors << "No such assessment id"
      false
    else
      @payload[:income][:wage_slips]&.each do |slip|
        create_wage_slip(slip)
      end
      @payload[:income][:benefits]&.each do |benefit_params|
        create_benefit(benefit_params)
      end
      @errors.flatten!
      @result == :ok
    end
  end


  def create_wage_slip(params)
    wage_slip = @assessment.wage_slips.new(params)
    unless wage_slip.save
      @result = :error
      @errors << wage_slip.errors.full_messages
    end
  end

  def create_benefit(params)
    benefit = @assessment.benefit_receipts.new(params)
    unless benefit.save
      @result = :error
      @errors << benefit.errors.full_messages
    end
  end

  def success_response
    {
      status: :ok,
      assessment_id: @assessment.id,
      links: [
        {
          href: assessment_properties_path(@assessment),
          rel: 'properties',
          type: 'POST'
        }
      ]
    }.to_json
  end

  def error_response
    {
      status: :error,
      assessment_id: @payload[:assessment_id],
      errors: @errors
    }.to_json
  end
end

