module Decorators
  module V4
    class CapitalDecorator
      def initialize(assessment)
        @assessment = assessment
        @summary = assessment.capital_summary
      end

      def as_json
        payload unless @summary.nil?
      end

    private

      def payload
        {
          capital_items: capital_items
        }
      end

      def capital_items
        {
          liquid: liquid_items,
          non_liquid: non_liquid_items,
          vehicles: vehicles,
          properties: properties
        }
      end

      def properties
        {
          main_home: PropertyDecorator.new(@summary.main_home)&.as_json,
          additional_properties: additional_properties
        }
      end

      def liquid_items
        @summary.liquid_capital_items.map { |i| CapitalItemDecorator.new(i).as_json }
      end

      def non_liquid_items
        @summary.non_liquid_capital_items.map { |ni| CapitalItemDecorator.new(ni).as_json }
      end

      def additional_properties
        @summary.additional_properties.map { |p| PropertyDecorator.new(p).as_json }
      end

      def vehicles
        @summary.vehicles.map { |v| VehicleDecorator.new(v).as_json }
      end
    end
  end
end
