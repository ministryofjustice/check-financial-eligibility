class DependentCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/dependent.json').to_s

  def initialize(raw_post)
    @raw_post =  raw_post
    @payload = JSON.parse(@raw_post, symbolize_names: true)
    @errors = []
  end

  def success?
    errors.empty?
  end

  def assessment
    @assessment ||= Assessment.find(@payload[:assessment_id])
  end

  def errors
    validator.valid? ? model_errors : validator.errors
  end

  private

  def validator
    @validator ||= JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
  end

  def model_errors
    @model_errors ||= create_dependents
  end

  def create_dependents
    errors = []
    ActiveRecord::Base.transaction do
      @payload[:dependents].each do |dependent_params|
        income_params = dependent_params.delete(:income)
        dependent = assessment.dependents.new(dependent_params)
        income_params&.each do |ip|
          dependent.dependent_income_receipts.new(ip)
        end
        next if dependent.save

        errors << collect_errors(dependent)
      end
    end
    errors.flatten
  end

  def collect_errors(dependent)
    dependent.errors.full_messages + income_receipt_errors(dependent)
  end

  def income_receipt_errors(dependent)
    dependent.dependent_income_receipts.map { |ir| ir.errors.full_messages }
  end
end
