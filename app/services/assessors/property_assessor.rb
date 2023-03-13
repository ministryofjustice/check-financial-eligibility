module Assessors
  class PropertyAssessor
    Result = Struct.new(:transaction_allowance,
                        :net_value,
                        :net_equity,
                        keyword_init: true)
    class << self
      def call(property:, allowable_outstanding_mortgage:, level_of_help:, submission_date:)
        transaction_allowance_cap = property_transaction_allowance_cap(property, level_of_help, submission_date)
        equity = property.value - allowable_outstanding_mortgage
        transaction_allowance = Utilities::NumberUtilities.negative_to_zero [equity, transaction_allowance_cap].min
        net_value = equity - transaction_allowance
        net_equity = calculate_net_equity(property, net_value)
        Result.new(transaction_allowance:, net_value:, net_equity:)
                       .freeze
      end

    private

      def property_transaction_allowance_cap(property, level_of_help, submission_date)
        level_of_help == "controlled" ? 0.0 : (property.value * notional_transaction_cost_pctg(submission_date)).round(2)
      end

      def notional_transaction_cost_pctg(submission_date)
        Threshold.value_for(:property_notional_sale_costs_percentage, at: submission_date) / 100.0
      end

      def calculate_net_equity(property, net_value)
        if property.shared_with_housing_assoc
          (net_value - housing_association_share(property)).round(2)
        else
          (net_value * shared_ownership_percentage(property)).round(2)
        end
      end

      def housing_association_share(property)
        property.value * (1 - shared_ownership_percentage(property))
      end

      def shared_ownership_percentage(property)
        property.percentage_owned / 100.0
      end
    end
  end
end
