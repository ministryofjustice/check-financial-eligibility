module Decorators
  module V5
    class ResultSummaryDecorator
      attr_reader :assessment

      delegate :capital_summary,
               :disposable_income_summary,
               :gross_income_summary,
               to: :assessment

      def initialize(assessment)
        @assessment = assessment
      end

      def as_json
        {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: capital_summary.combined_capital_contribution.to_f,
            income_contribution: disposable_income_summary.income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(assessment).as_json,
          },
          gross_income: GrossIncomeResultDecorator.new(gross_income_summary).as_json,
          partner_gross_income:,
          disposable_income: DisposableIncomeResultDecorator.new(disposable_income_summary,
                                                                 gross_income_summary).as_json,
          partner_disposable_income:,
          capital: CapitalResultDecorator.new(capital_summary).as_json,
          partner_capital:,
        }
      end

      def partner_gross_income
        return unless assessment.partner

        GrossIncomeResultDecorator.new(assessment.partner_gross_income_summary).as_json
      end

      def partner_disposable_income
        return unless assessment.partner

        DisposableIncomeResultDecorator.new(assessment.partner_disposable_income_summary,
                                            assessment.partner_gross_income_summary).as_json
      end

      def partner_capital
        return unless assessment.partner

        CapitalResultDecorator.new(assessment.partner_capital_summary).as_json
      end
    end
  end
end
