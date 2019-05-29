module WorkflowService
  class DisposableCapitalAssessment < BaseWorkflowService

    def result_for
      calculate_liquid_capital
      calculate_property
      true
    end

    private

    def calculate_liquid_capital
      total_liquid_capital = 0.0

      @particulars.request.applicant_capital.liquid_capital.bank_accounts.each do |acct|
        total_liquid_capital += acct.lowest_balance if acct.lowest_balance.positive?
      end
      @particulars.response.details.liquid_capital_assessment = total_liquid_capital.round(2)
    end

    def calculate_property
      @remaining_mortgage_allowance = Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
      calculate_additional_properties
      calculate_main_dwelling(request_data: @particulars.request.applicant_capital.property.main_home,  response_data: @particulars.response.details.capital.property.main_dwelling)
    end

    def calculate_additional_properties
      # @particulars.request.applicant_capital.property.additional_properties.each do |additional_property|
      #   calculate_additional_property(additional_property)
      # end
    end

    def calculate_main_dwelling(request_data:, response_data:)
      calculate_individual_property(request_data: request_data, response_data: response_data, property_type: :main_dwelling)
    end

    def calculate_individual_property(request_data:, response_data:, property_type:)
      response_data.notional_sale_costs_pctg = Threshold.value_for(:property_notional_sale_costs_percentage, at: @submission_date)
      response_data.net_value_after_deduction = (request_data.value - (request_data.value * (response_data.notional_sale_costs_pctg / 100))).round(2)
      response_data.maximum_mortgage_allowance = allowable_mortgage_deduction(request_data.outstanding_mortgage)
      response_data.net_value_after_mortgage = response_data.net_value_after_deduction - response_data.maximum_mortgage_allowance
      response_data.percentage_owned = request_data.percentage_owned
      response_data.net_equity_value = (response_data.net_value_after_mortgage * (response_data.percentage_owned / 100)).round(2)
      response_data.property_disregard = Threshold.value_for(:property_main_dwelling_disregard, at: @submission_date)
      response_data.assessed_capital_value = (response_data.net_equity_value - response_data.property_disregard).round(2)
    end

    def calculate_additional_property(additional_property)
      puts ">>>>>>>>>> additional_property #{__FILE__}:#{__LINE__} <<<<<<<<<<"
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

  end
end
