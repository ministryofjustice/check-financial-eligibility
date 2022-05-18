module Creators
  class DependantsCreator < BaseCreator
    attr_accessor :assessment_id, :dependants_attributes, :dependants

    def initialize(assessment_id:, dependants_attributes:)
      super()
      @assessment_id = assessment_id
      @dependants_attributes = dependants_attributes
    end

    def call
      create_records
      self
    end

  private

    def create_records
      create_dependants
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_dependants
      validate_in_full_time_education if assessment.assessment_type != "criminal"

      self.dependants = assessment.dependants.create!(dependants_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def validate_in_full_time_education
      dependants_attributes.each do |dependant|
        raise CreationError, ["in_full_time_education cannot be nil for a civil assessment"] if dependant[:in_full_time_education].nil?
      end
    end
  end
end
