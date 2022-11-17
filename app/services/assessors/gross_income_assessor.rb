module Assessors
  class GrossIncomeAssessor
    class << self
      def call(eligibilities:, total_gross_income:)
        eligibilities.each { |e| e.update_assessment_result! total_gross_income }
      end
    end
  end
end
