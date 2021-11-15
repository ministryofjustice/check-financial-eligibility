module Utilities
  # class to calculate the overall given an array of results (from the eligibility records for each proceeding type)
  class ResultSummarizer
    def self.call(individual_results)
      return :pending if individual_results.empty?

      summarized_results(individual_results.uniq.map(&:to_sym))
    end

    def self.summarized_results(uniq_results)
      return :pending if uniq_results.include?(:pending)

      return :eligible if uniq_results == [:eligible]

      return :ineligible if uniq_results == [:ineligible]

      return :contribution_required if uniq_results == [:contribution_required]

      return :contribution_required unless uniq_results.include?(:ineligible)

      :partially_eligible
    end

    private_class_method :summarized_results
  end
end
