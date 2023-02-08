module Assessors
  class VehicleAssessor
    Result = Struct.new(:value, :included_in_assessment, keyword_init: true)
    class << self
      def call(vehicles, submission_date)
        vehicles.sum { assess(_1, submission_date) }
      end

      def assess(vehicle, submission_date)
        result = if vehicle.in_regular_use?
                   assess_in_regular_use(vehicle, submission_date)
                 else
                   assess_not_in_regular_use(vehicle)
                 end
        save_assessed_value(vehicle, result)
        result.value
      end

    private

      def assess_in_regular_use(vehicle, submission_date)
        net_value = vehicle.value - vehicle.loan_amount_outstanding
        if too_old_to_count(vehicle, submission_date) || net_value <= vehicle_disregard(submission_date)
          Result.new(value: 0, included_in_assessment: false).freeze
        else
          Result.new(value: net_value - vehicle_disregard(submission_date), included_in_assessment: true).freeze
        end
      end

      def assess_not_in_regular_use(vehicle)
        Result.new(value: vehicle.value, included_in_assessment: true).freeze
      end

      def too_old_to_count(vehicle, submission_date)
        age_in_months(vehicle, submission_date) >= vehicle_out_of_scope_age(submission_date)
      end

      # TODO: remove this side effect
      def save_assessed_value(vehicle, result)
        vehicle.update!(assessed_value: result.value, included_in_assessment: result.included_in_assessment)
      end

      def age_in_months(vehicle, submission_date)
        Calculators::VehicleAgeCalculator.new(vehicle.date_of_purchase, submission_date).in_months
      end

      def vehicle_out_of_scope_age(submission_date)
        Threshold.value_for(:vehicle_out_of_scope_months, at: submission_date)
      end

      def vehicle_disregard(submission_date)
        Threshold.value_for(:vehicle_disregard, at: submission_date)
      end
    end
  end
end
