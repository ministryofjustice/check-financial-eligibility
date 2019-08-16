module WorkflowService
  class PropertyAssessment < BaseWorkflowService
    def call
      calculate_property
      capital_summary.properties.sum(&:assessed_equity)
    end

    private

    def calculate_property
      calculate_additional_properties unless additional_properties.empty?
      calculate_main_home(property: main_home) unless main_home.nil?
    end

    def calculate_additional_properties
      additional_properties.each do |additional_property|
        calculate_individual_property(property: additional_property, property_type: :additional_property)
      end
    end

    def calculate_main_home(property:)
      calculate_individual_property(property: property, property_type: :main_home)
    end

    def calculate_individual_property(property:, property_type:)
      calculate_property_transaction_allowance(property)
      calculate_outstanding_mortgage(property)
      calculate_net_value(property)
      calculate_net_equity(property)
      calculate_main_home_disregard(property, property_type)
      calculate_assessed_equity(property)
      property.save!
    end

    def calculate_property_transaction_allowance(property)
      property.transaction_allowance = (property.value * notional_transaction_cost_pctg).round(2)
    end

    def calculate_outstanding_mortgage(property)
      property.allowable_outstanding_mortgage = allowable_mortgage_deduction(property.outstanding_mortgage)
    end

    def calculate_net_value(property)
      property.net_value = property.value - property.transaction_allowance - property.allowable_outstanding_mortgage
    end

    def calculate_net_equity(property)
      property.net_equity = (property.net_value * percentage_owned(property)).round(2)
    end

    def calculate_main_home_disregard(property, property_type)
      property.main_home_equity_disregard = property_disregard(property_type)
    end

    def calculate_assessed_equity(property)
      property.assessed_equity = property.net_equity - property.main_home_equity_disregard
    end

    def notional_transaction_cost_pctg
      Threshold.value_for(:property_notional_sale_costs_percentage, at: @submission_date) / 100.0
    end

    def percentage_owned(property)
      property.percentage_owned / 100.0
    end

    def asssessed_equity(property)
      [0, (property.net_equity - property.main_home_equity_disregard).round(2)].max
    end

    def allowable_mortgage_deduction(outstanding_mortgage)
      if outstanding_mortgage > remaining_mortgage_allowance
        result = remaining_mortgage_allowance
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

    def remaining_mortgage_allowance
      @remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end
  end
end
