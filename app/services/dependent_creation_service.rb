class DependentCreationService
  include Rails.application.routes.url_helpers

  SCHEMA_PATH = Rails.root.join('public/schemas/dependent.json').to_s

  attr_reader :http_status

  def initialize(payload)
    @payload = JSON.parse(payload, symbolize_names: true)
    @raw_payload = payload
  end

  def result_payload
    if create_dependents
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

  def create_dependents
    return false unless json_payload_valid?

    @assessment = Assessment.find(@payload[:assessment_id])
    @payload[:dependents].each do |dependent_params|
      income_params = dependent_params.delete(:income)
      dependent = @assessment.dependents.new(dependent_params)
      income_params&.each do |ip|
        dependent.dependent_income_receipts.new(ip)
      end
      next if dependent.save

      collect_errors(dependent)
      return false
    end
    true
  end

  def collect_errors(dependent)
    @errors = dependent.errors.full_messages
    dependent.dependent_income_receipts.each do |dir|
      @errors += dir.errors.full_messages
    end
  end

  def success_response
    {
      status: :ok,
      assessment_id: @assessment.id,
      links: [
        {
          href: assessment_properties_path(@assessment),
          rel: 'capital',
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
