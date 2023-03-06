module Decorators
  module V5
    class CapitalDecorator
      def initialize(summary, capital_subtotals)
        @summary = summary
        @capital_subtotals = capital_subtotals
      end

      def as_json
        payload
      end

    private

      def payload
        {
          capital_items:,
        }
      end

      def capital_items
        {
          liquid: liquid_items,
          non_liquid: non_liquid_items,
          vehicles:,
          properties:,
        }
      end

      def properties
        {
          main_home: PropertyDecorator.new(@capital_subtotals.main_home).as_json,
          additional_properties:,
        }
      end

      def liquid_items
        @summary.liquid_capital_items.map { |i| CapitalItemDecorator.new(i).as_json }
      end

      def non_liquid_items
        @summary.non_liquid_capital_items.map { |ni| CapitalItemDecorator.new(ni).as_json }
      end

      def additional_properties
        @capital_subtotals.additional_properties.map { |p| PropertyDecorator.new(p).as_json }
      end

      def vehicles
        @summary.vehicles.map { |v| VehicleDecorator.new(v).as_json }
      end
    end
  end
end
