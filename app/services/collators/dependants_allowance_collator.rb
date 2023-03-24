module Collators
  class DependantsAllowanceCollator
    class << self
      def call(dependants:, submission_date:)
        dependants.each do |dependant|
          dependant.update!(dependant_allowance: Calculators::DependantAllowanceCalculator.call(dependant, submission_date))
        end
        dependants.sum(&:dependant_allowance)
      end
    end
  end
end
