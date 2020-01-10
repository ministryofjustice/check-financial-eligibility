module Decorators
  class CapitalSummaryDecorator
    attr_reader :assessment

    def initialize(record)
      @record = record
    end

    def as_json # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return nil if @record.nil?

      {
        capital_items: {
          liquid: liquid_items,
          non_liquid: non_liquid_items,
          vehicles: vehicles,
          properties: {
            main_home: PropertyDecorator.new(@record.main_home)&.as_json,
            additional_properties: additional_properties
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
        lower_threshold: @record.lower_threshold,
        upper_threshold: @record.upper_threshold,
        assessment_result: @record.assessment_result,
        capital_contribution: @record.capital_contribution
      }
    end

    private

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
