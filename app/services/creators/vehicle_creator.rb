module Creators
  class VehicleCreator < BaseCreator
    attr_accessor :assessment_id, :vehicles

    def initialize(assessment_id:, vehicles_params:, capital_summary: nil)
      super()
      @assessment_id = assessment_id
      @vehicles_params = vehicles_params
      @explicit_capital_summary = capital_summary
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

    def vehicles_attributes
      @vehicles_attributes ||= JSON.parse(@vehicles_params, symbolize_names: true)[:vehicles]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("vehicles", @vehicles_params)
    end

    def capital_summary
      @explicit_capital_summary || assessment.capital_summary
    end
  end
end
