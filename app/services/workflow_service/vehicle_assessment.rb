module WorkflowService
  class VehicleAssessment < BaseWorkflowService
    def call
      applicant_capital.liquid_capital.vehicles.each { |v| assess(v) }
      true
    end

    private

    def assess(vehicle)
      result = OpenStruct.new(AssessmentParticulars.initial_vehicle_details)
      copy_request_details_to_result(vehicle, result)
      result.assessed_value = assessed_value(vehicle)
      response.details.capital.vehicles << result
    end

    def vehicle_disregard
      @vehicle_disregard ||= Threshold.value_for(:vehicle_disregard, at: @submission_date)
    end

    def vehicle_age_in_months(vehicle)
      VehicleAgeCalculator.new(vehicle.date_of_purchase, @submission_date).in_months
    end

    def copy_request_details_to_result(request, result)
      %i[value loan_amount_outstanding date_of_purchase in_regular_use].each do |meth|
        result.__send__("#{meth}=", request.__send__(meth))
      end
    end

    def vehicle_out_of_scope_age
      Threshold.value_for(:vehicle_out_of_scope_months, at: @submission_date)
    end

    def assessed_value(vehicle)
      vehicle.in_regular_use ? regularly_used_assessed_value(vehicle) : non_regularly_used_assessed_value(vehicle)
    end

    def regularly_used_assessed_value(vehicle)
      net_value = vehicle.value - vehicle.loan_amount_outstanding
      if vehicle_age_in_months(vehicle) >= vehicle_out_of_scope_age || net_value <= vehicle_disregard
        0
      else
        [0, in_scope_assessed_value(vehicle, net_value)].max
      end
    end

    def capital_percentages
      @capital_percentages ||= Threshold.value_for(:vehicle_capital_value_pctg, at: Date.today)[:months]
    end

    def in_scope_assessed_value(vehicle, net_value)
      pctg_value = get_capital_percentage(vehicle_age_in_months(vehicle))
      (net_value * pctg_value / 100) - vehicle_disregard
    end

    def non_regularly_used_assessed_value(vehicle)
      vehicle.value
    end

    def get_capital_percentage(age_in_months)
      key = capital_percentages.keys.select { |k| k > age_in_months }.min || capital_percentages.keys.max
      capital_percentages[key]
    end
  end
end
