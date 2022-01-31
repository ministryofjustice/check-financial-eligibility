module Creators
  class VehicleCreator < BaseCreator
    attr_accessor :assessment_id, :vehicles_attributes, :vehicles

    def initialize(assessment_id:, vehicles_attributes:)
      super()
      @assessment_id = assessment_id
      @vehicles_attributes = vehicles_attributes
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
      self.vehicles = capital_summary.vehicles.create!(vehicles_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ["No such assessment id"])
    end

    def capital_summary
      @capital_summary ||= assessment.capital_summary
    end
  end
end
