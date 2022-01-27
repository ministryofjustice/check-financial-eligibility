module Calculators
  class PropertyCalculator < BaseWorkflowService
    attr_writer :remaining_mortgage_allowance

    def call
      calculate_property
      capital_summary.properties.sum(&:assessed_equity)
    end

    def remaining_mortgage_allowance
      @remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
    end

  private

    def calculate_property
      Property.transaction do
        capital_summary.additional_properties.each do |property|
          property.assess_equity!(remaining_mortgage_allowance)
          self.remaining_mortgage_allowance -= property.allowable_outstanding_mortgage
        end
        capital_summary.main_home&.assess_equity!(remaining_mortgage_allowance)
      end
    end
  end
end
