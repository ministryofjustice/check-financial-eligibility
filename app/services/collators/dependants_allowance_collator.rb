module Collators
  class DependantsAllowanceCollator
    class << self
      def call(dependants:, disposable_income_summary:)
        new(dependants:, disposable_income_summary:).call
      end
    end

    def initialize(dependants:, disposable_income_summary:)
      @dependants = dependants
      @disposable_income_summary = disposable_income_summary
    end

    def call
      @dependants.each do |dependant|
        dependant.update!(dependant_allowance: Calculators::DependantAllowanceCalculator.call(dependant))
      end
      collate!
    end

  private

    def collate!
      @disposable_income_summary.update!(dependant_allowance: @dependants.sum(&:dependant_allowance)) if @dependants.any?
    end
  end
end
