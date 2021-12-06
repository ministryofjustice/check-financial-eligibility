module Decorators
  module V5
    class ResultSummaryDecorator
      # class aliases for V4
      CapitalResultDecorator = ::Decorators::V4::CapitalResultDecorator
      GrossIncomeResultDecorator = ::Decorators::V4::GrossIncomeResultDecorator
      MatterTypeResultDecorator = ::Decorators::V4::MatterTypeResultDecorator
      ProceedingTypesResultDecorator = ::Decorators::V4::ProceedingTypesResultDecorator

      attr_reader :assessment

      delegate :capital_summary,
               :disposable_income_summary,
               to: :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json # rubocop:disable Metrics/MethodLength
        {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: capital_summary.capital_contribution.to_f,
            income_contribution: disposable_income_summary.income_contribution.to_f,
            matter_types: MatterTypeResultDecorator.new(@assessment).as_json,
            proceeding_types: ProceedingTypesResultDecorator.new(@assessment).as_json
          },
          gross_income: GrossIncomeResultDecorator.new(@assessment).as_json,
          disposable_income: DisposableIncomeResultDecorator.new(@assessment).as_json,
          capital: CapitalResultDecorator.new(@assessment).as_json
        }
      end
    end
  end
end
