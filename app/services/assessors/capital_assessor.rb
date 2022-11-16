module Assessors
  class CapitalAssessor
    class << self
      def call(capital_summary, assessed_capital)
        capital_summary.eligibilities.each { |elig| elig.update_assessment_result! assessed_capital }
        summary_result capital_summary
      end

    private

      def summary_result(capital_summary)
        Utilities::ResultSummarizer.call(capital_summary.eligibilities.map(&:assessment_result))
      end
    end
  end
end
