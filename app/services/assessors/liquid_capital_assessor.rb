module Assessors
  class LiquidCapitalAssessor
    class << self
      def call(capital_summary)
        total_liquid_capital = 0.0
        capital_summary.liquid_capital_items.each do |item|
          total_liquid_capital += item.value if item.value.positive?
        end
        total_liquid_capital.round(2)
      end
    end
  end
end
