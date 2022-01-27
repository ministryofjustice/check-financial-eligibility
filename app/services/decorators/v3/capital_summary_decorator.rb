module Decorators
  module V3
    class CapitalSummaryDecorator
      def initialize(capital_summary)
        @record = capital_summary
      end

      def as_json
        payload unless @record.nil?
      end

    private

      def payload # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          capital_items: {
            liquid: liquid_items,
            non_liquid: non_liquid_items,
            vehicles:,
            properties: {
              main_home: PropertyDecorator.new(@record.main_home)&.as_json,
              additional_properties:
            }
          },
          total_liquid: @record.total_liquid,
          total_non_liquid: @record.total_non_liquid,
          total_vehicle: @record.total_vehicle,
          total_property: @record.total_property,
          total_mortgage_allowance: @record.total_mortgage_allowance,
          total_capital: @record.total_capital,
          pensioner_capital_disregard: @record.pensioner_capital_disregard,
          assessed_capital: @record.assessed_capital,
          lower_threshold: @record.eligibilities.first.lower_threshold,
          upper_threshold: @record.eligibilities.first.upper_threshold,
          assessment_result: @record.summarized_assessment_result,
          capital_contribution: @record.capital_contribution
        }
      end

      def liquid_items
        @record.liquid_capital_items.map { |i| CapitalItemDecorator.new(i).as_json }
      end

      def non_liquid_items
        @record.non_liquid_capital_items.map { |ni| CapitalItemDecorator.new(ni).as_json }
      end

      def additional_properties
        @record.additional_properties.map { |p| PropertyDecorator.new(p).as_json }
      end

      def vehicles
        @record.vehicles.map { |v| VehicleDecorator.new(v).as_json }
      end
    end
  end
end
