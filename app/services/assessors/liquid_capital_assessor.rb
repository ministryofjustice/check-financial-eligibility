module Assessors
  class LiquidCapitalAssessor < BaseWorkflowService
    def call
      total_liquid_capital = 0.0
      liquid_capital_items.each do |item|
        total_liquid_capital += item.value if item.value.positive?
      end
      total_liquid_capital.round(2)
    end
  end
end
