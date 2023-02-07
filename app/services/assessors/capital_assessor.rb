module Assessors
  class CapitalAssessor
    class << self
      def call(capital_summary, assessed_capital)
        capital_summary.eligibilities.each { |elig| elig.update_assessment_result! assessed_capital }
        threshold = capital_summary.eligibilities.map(&:lower_threshold).min
        [0, assessed_capital - threshold].max
      end
    end
  end
end
