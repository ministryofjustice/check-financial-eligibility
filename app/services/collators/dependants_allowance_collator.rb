module Collators
  class DependantsAllowanceCollator
    class << self
      def call(dependants:, disposable_income_summary:, submission_date:)
        new(dependants:, disposable_income_summary:, submission_date:).call
      end
    end

    def initialize(dependants:, disposable_income_summary:, submission_date:)
      @dependants = dependants
      @disposable_income_summary = disposable_income_summary
      @submission_date = submission_date
    end

    def call
      @dependants.each do |dependant|
        dependant.update!(dependant_allowance: Calculators::DependantAllowanceCalculator.call(dependant, @submission_date))
      end
      collate!
    end

  private

    def collate!
      @disposable_income_summary.update!(dependant_allowance: @dependants.sum(&:dependant_allowance)) if @dependants.any?
    end
  end
end
