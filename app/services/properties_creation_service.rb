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
    validator = JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
    return true if validator.valid?
    @errors = validator.errors
    false
  end

  def assessment_exists?
    @assessment = Assessment.find_by(id: @payload[:assessment_id])
    if @assessment.nil?
      @errors << 'No such assessment id'
      return false
    end
    true
  end

  def create_properties
    new_main_home
    new_additional_properties
    return true if @assessment.save

    collect_model_errors
    false
  end

  def new_main_home
    if @payload[:properties][:main_home]
      new_property(@payload[:properties][:main_home], true)
    end
  end

  def new_property(attrs, main_home)
    attrs[:main_home] = main_home
    @assessment.properties.new(attrs)
  end

  def new_additional_properties
    if @payload[:properties][:additional_properties]
      @payload[:properties][:additional_properties].each do |attrs|
        new_property(attrs, false)
      end
    end
  end

  def collect_model_errors
    @errors = @assessment.errors.full_messages
    @assessment.properties.each do |property|
      @errors += property.errors.full_messages
    end
  end

  def success_response
    OpenStruct.new(
      success: true,
      objects: @assessment.properties,
      errors: []
    )
  end

  def error_response
    OpenStruct.new(
                success: false,
                objects: nil,
                errors: @errors
    )
  end
end
