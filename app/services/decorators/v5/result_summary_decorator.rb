module Decorators
  module V5
    class ResultSummaryDecorator
      attr_reader :assessment

      delegate :capital_summary,
               :disposable_income_summary,
               to: :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: capital_summary.capital_contribution.to_f,
            income_contribution: disposable_income_summary.income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(@assessment).as_json,
          },
          gross_income: GrossIncomeResultDecorator.new(@assessment).as_json,
          disposable_income: DisposableIncomeResultDecorator.new(@assessment).as_json,
          capital: CapitalResultDecorator.new(@assessment).as_json,
        }
      end
    end
  end
end
