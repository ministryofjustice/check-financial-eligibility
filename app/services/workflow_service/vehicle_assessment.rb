module WorkflowService
  class VehicleAssessment < BaseWorkflowService
    def call
      vehicles.each { |v| assess(v) }
      vehicles.sum(&:assessed_value)
    end

    private

    def response
      @response ||= []
    end

    def assess(vehicle)
      if vehicle.in_regular_use
        assess_vehicle_in_regular_use(vehicle)
      else
        assess_vehicle_not_in_regular_use(vehicle)
      end
      vehicle.save!
    end

    def assess_vehicle_not_in_regular_use(vehicle)
      vehicle.included_in_assessment = true
      vehicle.assessed_value = vehicle.value
    end

    def assess_vehicle_in_regular_use(vehicle)
      net_value = vehicle.value - vehicle.loan_amount_outstanding
      if vehicle_age_in_months(vehicle) >= vehicle_out_of_scope_age || net_value <= vehicle_disregard
        vehicle.included_in_assessment = false
        vehicle.assessed_value = 0
      else
        vehicle.included_in_assessment = true
        vehicle.assessed_value = net_value - vehicle_disregard
      end
    end

    def vehicle_disregard
      @vehicle_disregard ||= Threshold.value_for(:vehicle_disregard, at: @submission_date)
    end

    def vehicle_age_in_months(vehicle)
      VehicleAgeCalculator.new(vehicle.date_of_purchase, @submission_date).in_months
    end

    def vehicle_out_of_scope_age
      Threshold.value_for(:vehicle_out_of_scope_months, at: @submission_date)
    end

    def assessed_value(vehicle)
      vehicle.in_regular_use ? regularly_used_assessed_value(vehicle) : non_regularly_used_assessed_value(vehicle)
    end
  end
end
