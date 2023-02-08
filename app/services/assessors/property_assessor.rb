module Assessors
  class PropertyAssessor
    Result = Struct.new(:transaction_allowance,
                        :allowable_outstanding_mortgage,
                        :net_value,
                        :net_equity,
                        :main_home_equity_disregard,
                        :assessed_equity,
                        keyword_init: true)
    class << self
      def call(property, remaining_mortgage_allowance, level_of_representation, submission_date)
        transaction_allowance = calculate_property_transaction_allowance(property, level_of_representation, submission_date)
        allowable_outstanding_mortgage = calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
        net_value = calculate_net_value(property, transaction_allowance, allowable_outstanding_mortgage)
        net_equity = calculate_net_equity(property, net_value)
        main_home_equity_disregard = calculate_main_home_disregard(property, submission_date)
        assessed_equity = calculate_assessed_equity(net_equity, main_home_equity_disregard)
        result = Result.new(transaction_allowance:, allowable_outstanding_mortgage:, net_value:, net_equity:, main_home_equity_disregard:, assessed_equity:)
                       .freeze
        save!(property, result)
        result
      end

    private

      def calculate_property_transaction_allowance(property, level_of_representation, submission_date)
        level_of_representation == "controlled" ? 0 : (property.value * notional_transaction_cost_pctg(submission_date)).round(2)
      end

      def notional_transaction_cost_pctg(submission_date)
        Threshold.value_for(:property_notional_sale_costs_percentage, at: submission_date) / 100.0
      end

      def calculate_outstanding_mortgage(property, remaining_mortgage_allowance)
        property.outstanding_mortgage > remaining_mortgage_allowance ? remaining_mortgage_allowance : property.outstanding_mortgage
      end

      def calculate_net_value(property, transaction_allowance, allowable_outstanding_mortgage)
        property.value - transaction_allowance - allowable_outstanding_mortgage
      end

      def calculate_net_equity(property, net_value)
        property.shared_with_housing_assoc ? (net_value - housing_association_share(property)).round(2) : (net_value * shared_ownership_percentage(property)).round(2)
      end

      def shared_ownership_percentage(property)
        property.percentage_owned / 100.0
      end

      def calculate_main_home_disregard(property, submission_date)
        property_type = property.main_home ? :main_home : :additional_property
        Threshold.value_for(:property_disregard, at: submission_date)[property_type]
      end

      def calculate_assessed_equity(net_equity, main_home_equity_disregard)
        [net_equity - main_home_equity_disregard, 0].max
      end

      def housing_association_share(property)
        property.value * (1 - shared_ownership_percentage(property))
      end

      # TODO: Remove this side effect
      def save!(property, result)
        property.update!(result.as_json)
      end
    end
  end
end
