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
      calculate_main_dwelling(property: applicant_capital.property.main_home,
                              assessment: response.details.capital.property.main_dwelling)
    end

    def calculate_additional_properties
      applicant_capital.property.additional_properties.each do |additional_property|
        assessment = OpenStruct.new(AssessmentParticulars.initial_property_details)
        calculate_individual_property(property: additional_property, assessment: assessment, property_type: :additional_property)
        response.details.capital.property.additional_properties << assessment
      end
    end

    def calculate_main_dwelling(property:, assessment:)
      calculate_individual_property(property: property, assessment: assessment, property_type: :main_dwelling)
    end

    def calculate_individual_property(property:, assessment:, property_type:) # rubocop:disable Metrics/AbcSize
      assessment.notional_sale_costs_pctg = Threshold.value_for(:property_notional_sale_costs_percentage, at: @submission_date)
      assessment.net_value_after_deduction = (property.value - (property.value * (assessment.notional_sale_costs_pctg / 100))).round(2)
      assessment.maximum_mortgage_allowance = allowable_mortgage_deduction(property.outstanding_mortgage)
      assessment.net_value_after_mortgage = assessment.net_value_after_deduction - assessment.maximum_mortgage_allowance
      assessment.percentage_owned = property.percentage_owned
      assessment.net_equity_value = net_equity_value(property: property, assessment: assessment)
      assessment.property_disregard = property_disregard(property_type)
      assessment.assessed_capital_value = assessed_capital_value(assessment: assessment)
    end

    def net_equity_value(property:, assessment:)
      if property.shared_with_housing_assoc
        housing_assoc_pctg = 100 - property.percentage_owned
        assessment.net_value_after_mortgage - (property.value * housing_assoc_pctg / 100).round(2)
      else
        (assessment.net_value_after_mortgage * (assessment.percentage_owned / 100)).round(2)
      end
    end

    def assessed_capital_value(assessment:)
      [0, (assessment.net_equity_value - assessment.property_disregard).round(2)].max
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
