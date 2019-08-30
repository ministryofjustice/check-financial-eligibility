module WorkflowService
  class PropertyAssessment < BaseWorkflowService
    def call
      @remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
      calculate_property
      capital_summary.properties.sum(&:assessed_equity)
    end

    private

    def calculate_property
      Property.transaction do
        capital_summary.additional_properties.each do |property|
          property.assess_equity!(@remaining_mortgage_allowance)
          @remaining_mortgage_allowance -= property.allowable_outstanding_mortgage
        end
        capital_summary.main_home&.assess_equity!(@remaining_mortgage_allowance)
      end
    end
  end
end
