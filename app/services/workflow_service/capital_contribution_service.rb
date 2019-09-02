module WorkflowService
  class CapitalContributionService
    ABOVE_THRESHOLD_MESSAGE = 'Cannot calculate capital contribution where the assessed capital is greater than the upper disposable capital threshold'.freeze

    def self.call(capital_summary)
      new(capital_summary).call
    end

    def initialize(capital_summary)
      @capital_summary = capital_summary
    end

    def call
      raise 'Invalid capital assessment result for contribution calculation' unless @capital_summary.contribution_required?

      @capital_summary.assessed_capital - @capital_summary.lower_threshold
    end
  end
end
