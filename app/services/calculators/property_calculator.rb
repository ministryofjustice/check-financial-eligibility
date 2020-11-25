module Calculators
  class PropertyCalculator < BaseWorkflowService
    attr_writer :remaining_mortgage_allowance

    def call
      calculate_property
      capital_summary.properties.sum(&:assessed_equity)
    end

    def remaining_mortgage_allowance
      # TODO: remove remaining_mortgage_allowance on 8/1/2021
      return 0 unless Time.current.before?(Time.zone.parse('2021-01-08'))

      @remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)
    end

    private

    def calculate_property
      Property.transaction do
        capital_summary.additional_properties.each do |property|
          property.assess_equity!(remaining_mortgage_allowance)
          # TODO: remove -= (property.allowable_outstanding_mortgage || 0) on 8/1/2021
          self.remaining_mortgage_allowance -= (property.allowable_outstanding_mortgage || 0)
        end
        capital_summary.main_home&.assess_equity!(remaining_mortgage_allowance)
      end
    end
  end
end
