module Calculators
  class SubjectMatterOfDisputeDisregardCalculator < BaseWorkflowService
    def value
      total_disputed_asset_value = disputed_capital_value +
        disputed_property_value +
        disputed_vehicle_value

      [total_disputed_asset_value, threshold].min
    end

  private

    def threshold
      @threshold ||= Threshold.value_for(:subject_matter_of_dispute_disregard, at: submission_date) || 0
    end

    def disputed_capital_value
      capital_summary.capital_items.select(&:subject_matter_of_dispute).sum(&:value)
    end

    def disputed_property_value
      capital_summary.properties.select(&:subject_matter_of_dispute).sum(&:assessed_equity)
    end

    def disputed_vehicle_value
      vehicles.select(&:subject_matter_of_dispute).sum(&:assessed_value)
    end
  end
end
