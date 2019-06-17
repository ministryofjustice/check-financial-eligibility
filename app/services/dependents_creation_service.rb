class DependentsCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/dependent.json').to_s

  def initialize(raw_post)
    @raw_post =  raw_post
    @payload = JSON.parse(@raw_post, symbolize_names: true)
    @errors = nil
  end

  def success?
    errors.empty?
  end

  def assessment
    @assessment ||= Assessment.find_by(id: @payload[:assessment_id])
    @errors = ['No such assessment id'] if @assessment.nil?
    @assessment
  end

  def errors
    @errors ||= validator.valid? ? dependent_errors : validator.errors
  end

  private

  def validator
    @validator ||= JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
  end

  def model_errors
    @model_errors ||= create_dependents
  end

  def dependent_errors
    assessment.nil? ? @errors : model_errors
  end

  def create_dependents
    ar_errors = []
    ActiveRecord::Base.transaction do
      @payload[:dependents].each do |dependent_params|
        income_params = dependent_params.delete(:income)
        dependent = assessment.dependents.new(dependent_params)
        income_params&.each do |ip|
          dependent.dependent_income_receipts.new(ip)
        end
        next if dependent.save

        ar_errors << collect_errors(dependent)
      end
      ar_errors.flatten
    end
  end

  def collect_errors(dependent)
    dependent.errors.full_messages + income_receipt_errors(dependent)
  end

  def income_receipt_errors(dependent)
    dependent.dependent_income_receipts.map { |ir| ir.errors.full_messages }
  end
end
