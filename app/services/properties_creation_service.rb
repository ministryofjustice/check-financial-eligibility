class PropertiesCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/properties.json').to_s

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
      if create_properties
        return success_response
      end
    end
    error_response
  end

  private

  def json_valid?
    validator = JsonSchemaValidator.new(raw_post, SCHEMA_PATH)
    return true if validator.valid?
    @errors = validator.errors
    false
  end

  def assessment_exists?
    assessment = Assessment.find_by(id: @payload[:assessment_id])
    if assessment.nil?
      @errors << 'No such assessment id'
      return false
    end
    true
  end

  def create_properties
    
  end
end
