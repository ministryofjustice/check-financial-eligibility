module Creators
  class DependantsCreator < BaseCreator
    attr_accessor :assessment_id, :dependants_attributes, :dependants

    def initialize(assessment_id:, dependants_attributes:)
      super()
      @assessment_id = assessment_id
      @dependants_attributes = dependants_attributes
    end

    def call
      create
      self
    end

  private

    def create
      create_dependants
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_dependants
      self.dependants = assessment.dependants.create!(dependants_attributes)
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end
  end
end
