class VehicleCreationService < BaseCreationService
  attr_accessor :assessment_id, :vehicle_attributes, :vehicles

  def initialize(assessment_id:, vehicle_attributes:)
    @assessment_id = assessment_id
    @vehicle_attributes = vehicle_attributes
  end

  def call
    create
    self
  end

  private

  def create
    create_vehicles
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_vehicles
    self.vehicles = assessment.vehicles.create!(vehicle_attributes)
  rescue ActiveRecord::RecordInvalid => e
    raise CreationError, e.record.errors.full_messages
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end
end
