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
      delegate :main_home, :value,
               :outstanding_mortgage, :percentage_owned, :shared_with_housing_assoc, to: :property
    end

    Disregard = Data.define(:result, :applied)

    class << self
      def call(submission_date:, properties:, level_of_help:, smod_cap:)
        remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: submission_date)

        Property.transaction do
          (properties.select(&:main_home) + properties.reject(&:main_home)).map do |property|
            allowable_outstanding_mortgage = calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
            remaining_mortgage_allowance -= allowable_outstanding_mortgage
            assessor_result = Assessors::PropertyAssessor.call(property:,
                                                               allowable_outstanding_mortgage:,
                                                               level_of_help:,
                                                               submission_date:)

            smod_disregard = if property.subject_matter_of_dispute
                               apply_disregard(assessor_result.net_equity, smod_cap)
                             else
                               Disregard.new(result: assessor_result.net_equity, applied: 0)
                             end
            smod_cap -= smod_disregard.applied

            equity_disregard = apply_disregard smod_disregard.result, main_home_equity_disregard_cap(property, submission_date)

            Result.new(transaction_allowance: assessor_result.transaction_allowance,
                       net_value: assessor_result.net_value,
                       net_equity: assessor_result.net_equity,
                       main_home_equity_disregard: equity_disregard.applied,
                       property:,
                       smod_allowance: smod_disregard.applied,
                       assessed_equity: equity_disregard.result).freeze
          end
        end
      end

      def apply_disregard(equity, disregard)
        equity_after_disregard = Utilities::NumberUtilities.negative_to_zero equity - disregard
        Disregard.new(result: equity_after_disregard, applied: equity - equity_after_disregard)
      end

      def calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
        property.outstanding_mortgage > remaining_mortgage_allowance ? remaining_mortgage_allowance : property.outstanding_mortgage
      end

      def main_home_equity_disregard_cap(property, submission_date)
        property_type = property.main_home ? :main_home : :additional_property
        Threshold.value_for(:property_disregard, at: submission_date)[property_type]
      end
    end
  end
end
