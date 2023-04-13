module Creators
  class PropertiesCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(capital_summary:, properties_params:)
        new(capital_summary:, properties_params:).call
      end
    end

    def initialize(capital_summary:, properties_params:)
      @capital_summary = capital_summary
      @properties_params = properties_params
      @properties = []
    end

    def call
      create_properties
      Result.new(errors: []).freeze
    end

  private

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
      @capital_summary.properties.create!(attrs.merge(main_home:))
    end

    def main_home_attributes
      properties_attributes[:main_home]
    end

    def additional_properties_attributes
      properties_attributes[:additional_properties]
    end

    def properties_attributes
      @properties_params[:properties]
    end
  end
end
