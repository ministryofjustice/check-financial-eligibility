module Creators
  class PartnerPropertiesCreator < PropertiesCreator
  private

    def create_properties
      new_additional_properties
    end

    def capital_summary
      assessment.partner_capital_summary
    end

    def new_additional_properties
      @properties_params&.each do |attrs|
        new_property(attrs, false)
      end
    end

    def json_validator
      @json_validator ||= JsonValidator.new("additional_properties", @properties_params)
    end
  end
end
