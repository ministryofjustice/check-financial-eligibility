module Assessors
  class CapitalAssessor
    class << self
      def call(capital_summary, assessed_capital)
        capital_summary.eligibilities.each { |elig| elig.update_assessment_result! assessed_capital }
        set_capital_contribution(capital_summary, assessed_capital)
        summary_result(capital_summary)
      end

    private

      def summary_result(capital_summary)
        Utilities::ResultSummarizer.call(capital_summary.eligibilities.map(&:assessment_result))
      end

      def set_capital_contribution(capital_summary, assessed_capital)
        threshold = capital_summary.eligibilities.map(&:lower_threshold).min
        capital_summary.update!(capital_contribution: [0, assessed_capital - threshold].max)
      end
    end
  end
end
