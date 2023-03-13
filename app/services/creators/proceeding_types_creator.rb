module Creators
  class ProceedingTypesCreator < BaseCreator
    attr_accessor :proceeding_types

    def initialize(assessment_id:, proceeding_types_params:)
      super()
      @assessment_id = assessment_id
      @proceeding_types_params = proceeding_types_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

  private

    attr_reader :assessment_id

    def create_records
      create_proceeding_types
    rescue CreationError => e
      errors << e.errors
    end

    def create_proceeding_types
      self.proceeding_types = assessment.proceeding_types.create!(proceeding_types_attributes)
    rescue StandardError => e
      raise CreationError, "#{e.class} - #{e.message}"
    end

    def proceeding_types_attributes
      @proceeding_types_attributes ||= @proceeding_types_params[:proceeding_types]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("proceeding_types", @proceeding_types_params)
    end
  end
end
