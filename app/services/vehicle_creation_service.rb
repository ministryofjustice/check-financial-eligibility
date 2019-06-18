class VehicleCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/vehicles.json').to_s

  def initialize(raw_post)
    @raw_post = raw_post
    @payload = JSON.parse(@raw_post, symbolize_names: true)
    @errors = []
    @result = OpenStruct.new(success: nil, vehicles: nil, errors: [])
  end

  def call
    if json_valid? && assessment_exists?
      return success_result if create_vehicles
    end
    error_result
  end

  private

  def success_result
    @result.success = true
    @result.vehicles = @assessment.vehicles
    @result
  end

  def error_result
    @result.success = false
    @result.vehicles = nil
    @result.errors = @errors
    @result
  end

  def json_valid?
    validator ||= JsonSchemaValidator.new(@raw_post, SCHEMA_PATH)
    if validator.valid?
      true
    else
      @errors = ['Payload did not conform to JSON schema'] + validator.errors
      false
    end
  end

  def assessment_exists?
    @assessment = Assessment.find_by(id: @payload[:assessment_id])
    if @assessment
      true
    else
      @errors = ['No such assessment id'] if @assessment.nil?
      false
    end
  end

  def create_vehicles
    @payload[:vehicles].each do |vehicle_params|
      vehicle = @assessment.vehicles.new(vehicle_params)
      next if vehicle.valid?

      @errors += vehicle.errors.full_messages
    end
    @assessment.save if @errors.empty?
    @errors.empty?
  end
end
