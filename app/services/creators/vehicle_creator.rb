module Creators
  class VehicleCreator < BaseCreator
    attr_accessor :assessment_id, :vehicles

    def initialize(assessment_id:, vehicles_params:)
      super()
      @assessment_id = assessment_id
      @vehicles_params = vehicles_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        self.errors = json_validator.errors
      end
      self
    end

  private

    def create_records
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

    def vehicles_attributes
      @vehicles_attributes ||= JSON.parse(@vehicles_params, symbolize_names: true)[:vehicles]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("vehicles", @vehicles_params)
    end
  end
end
