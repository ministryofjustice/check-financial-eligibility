module Creators
  class PartnerPropertiesCreator < PropertiesCreator
  private

    def create_properties
      new_additional_properties
    end

    def new_additional_properties
      @properties_params.each do |attrs|
        new_property(attrs, false)
      end
    end
  end
end
