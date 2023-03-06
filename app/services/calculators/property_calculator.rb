module Calculators
  class PropertyCalculator
    Result = Struct.new(:transaction_allowance,
                        :net_value,
                        :net_equity,
                        :property,
                        :main_home_equity_disregard,
                        :assessed_equity,
                        :smod_allowance,
                        keyword_init: true) do
      delegate :main_home, :value, :percentage_owned,
               :outstanding_mortgage, :percentage_owned, :shared_with_housing_assoc, to: :property
    end

    class << self
      def call(submission_date:, properties:, level_of_help:, smod_level:)
        remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)

        Property.transaction do
          (properties.select(&:main_home) + properties.reject(&:main_home)).map do |property|
            allowable_outstanding_mortgage = calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
            remaining_mortgage_allowance -= allowable_outstanding_mortgage
            assessor_result = Assessors::PropertyAssessor.call(property:,
                                                               allowable_outstanding_mortgage:,
                                                               level_of_help:,
                                                               submission_date:)
            equity_disregard = calculate_main_home_disregard(property, submission_date)
            smod_applied = calculate_smod_disregard(property, assessor_result.net_equity, smod_level)
            smod_level -= smod_applied
            Result.new(transaction_allowance: assessor_result.transaction_allowance,
                       net_value: assessor_result.net_value,
                       net_equity: assessor_result.net_equity,
                       main_home_equity_disregard: equity_disregard,
                       property:,
                       smod_allowance: smod_applied,
                       assessed_equity: calculate_assessed_equity(assessor_result.net_equity - smod_applied,
                                                                  equity_disregard))
                  .freeze.tap do |result|
              save!(property, result)
            end
          end
        end
      end

      def calculate_smod_disregard(property, net_equity, smod_level)
        if property.subject_matter_of_dispute
          [net_equity, smod_level].min
        else
          0
        end
      end

      def calculate_assessed_equity(net_equity, main_home_equity_disregard)
        [net_equity - main_home_equity_disregard, 0.0].max
      end

      def calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
        property.outstanding_mortgage > remaining_mortgage_allowance ? remaining_mortgage_allowance : property.outstanding_mortgage
      end

      def calculate_main_home_disregard(property, submission_date)
        property_type = property.main_home ? :main_home : :additional_property
        Threshold.value_for(:property_disregard, at: submission_date)[property_type]
      end

      # TODO: Remove this side effect
      def save!(property, result)
        property.update!(result.to_h.except(:smod_allowance, :property))
      end
    end
  end
end
