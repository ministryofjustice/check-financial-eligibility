module Calculators
  class SubjectMatterOfDisputeDisregardCalculator < BaseWorkflowService
    delegate :disputed_capital_items, :disputed_vehicles, :disputed_properties, to: :capital_summary

    def value
      total_disputed_asset_value = disputed_capital_value +
        disputed_property_value +
        disputed_vehicle_value

      if total_disputed_asset_value.positive? && threshold.nil?
        raise "SMOD assets listed but no threshold data found for #{submission_date}"
      end

      [total_disputed_asset_value, threshold].compact.min
    end

  private

    def threshold
      @threshold ||= Threshold.value_for(:subject_matter_of_dispute_disregard, at: submission_date)
    end

    def disputed_capital_value
      disputed_capital_items.sum(:value)
    end

    def disputed_property_value
      disputed_properties.sum(:assessed_equity)
    end

    def disputed_vehicle_value
      disputed_vehicles.sum(:assessed_value)
    end
  end
end
