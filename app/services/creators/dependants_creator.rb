module Creators
  class DependantsCreator < BaseCreator
    attr_accessor :assessment_id, :dependants

    def initialize(assessment_id:, dependants_params:, relationship: :dependants)
      super()
      @assessment_id = assessment_id
      @dependants_params = dependants_params
      @relationship = relationship
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
      create_dependants
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_dependants
      self.dependants = assessment.send(@relationship).create!(dependants_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def dependants_attributes
      @dependants_attributes ||= JSON.parse(@dependants_params, symbolize_names: true)[:dependants]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("dependants", @dependants_params)
    end
  end
end
