module Creators
  class PropertiesCreator < BaseCreator
    attr_accessor :assessment_id, :properties

    delegate :capital_summary, to: :assessment

    def initialize(assessment_id:, properties_params:)
      super()
      @assessment_id = assessment_id
      @properties_params = properties_params
      @properties = []
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
      create_properties
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_properties
      new_main_home
      new_additional_properties
    end

    def new_main_home
      new_property(main_home_attributes, true) if main_home_attributes
    end

    def new_additional_properties
      additional_properties_attributes&.each do |attrs|
        new_property(attrs, false)
      end
    end

    def new_property(attrs, main_home)
      attrs[:main_home] = main_home
      @properties << capital_summary.properties.create!(attrs)
    end

    def main_home_attributes
      @main_home_attributes ||= properties_attributes[:main_home]
    end

    def additional_properties_attributes
      @additional_properties_attributes ||= properties_attributes[:additional_properties]
    end

    def properties_attributes
      @properties_attributes ||= @properties_params[:properties]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("properties", @properties_params)
    end
  end
end
