module Assessors
  class NonLiquidCapitalAssessor
    class << self
      def call(capital_summary)
        total_value = 0.0
        capital_summary.non_liquid_capital_items.each do |item|
          total_value += item.value
        end
        total_value.round(2)
      end
    end
  end
end
