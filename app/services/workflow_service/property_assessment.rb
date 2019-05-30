module WorkflowService
  class PropertyAssessment < BaseWorkflowService
    def call
      calculate_property
      true
    end

    private

    def calculate_property
      @remaining_mortgage_allowance = Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
      calculate_additional_properties
      calculate_main_dwelling(request_data: @particulars.request.applicant_capital.property.main_home,
                              response_data: @particulars.response.details.capital.property.main_dwelling)
    end

    def calculate_additional_properties
      @particulars.request.applicant_capital.property.additional_properties.each do |additional_property|
        response_data = OpenStruct.new(AssessmentParticulars.initial_property_details)
        calculate_individual_property(request_data: additional_property, response_data: response_data, property_type: :additional_property)
        @particulars.response.details.capital.property.additional_properties << response_data
      end
    end

    def calculate_main_dwelling(request_data:, response_data:)
      calculate_individual_property(request_data: request_data, response_data: response_data, property_type: :main_dwelling)
    end

    def calculate_individual_property(request_data:, response_data:, property_type:) # rubocop:disable Metrics/AbcSize
      response_data.notional_sale_costs_pctg = Threshold.value_for(:property_notional_sale_costs_percentage, at: @submission_date)
      response_data.net_value_after_deduction = (request_data.value - (request_data.value * (response_data.notional_sale_costs_pctg / 100))).round(2)
      response_data.maximum_mortgage_allowance = allowable_mortgage_deduction(request_data.outstanding_mortgage)
      response_data.net_value_after_mortgage = response_data.net_value_after_deduction - response_data.maximum_mortgage_allowance
      response_data.percentage_owned = request_data.percentage_owned
      response_data.net_equity_value = net_equity_value(request_data: request_data, response_data: response_data)
      response_data.property_disregard = property_disregard(property_type)
      response_data.assessed_capital_value = assessed_capital_value(response_data: response_data)
    end

    def net_equity_value(request_data:, response_data:)
      if request_data.shared_with_housing_assoc
        housing_assoc_pctg = 100 - request_data.percentage_owned
        response_data.net_value_after_mortgage - (request_data.value * housing_assoc_pctg / 100).round(2)
      else
        (response_data.net_value_after_mortgage * (response_data.percentage_owned / 100)).round(2)
      end
    end

    def assessed_capital_value(response_data:)
      [0, (response_data.net_equity_value - response_data.property_disregard).round(2)].max
    end

    def allowable_mortgage_deduction(outstanding_mortgage)
      if outstanding_mortgage > @remaining_mortgage_allowance
        result = @remaining_mortgage_allowance
        @remaining_mortgage_allowance = 0
      else
        result = outstanding_mortgage
        @remaining_mortgage_allowance -= result
      end
      result
    end

    def property_disregard(property_type)
      Threshold.value_for(:property_disregard, at: @submission_date)[property_type]
    end
  end
end
