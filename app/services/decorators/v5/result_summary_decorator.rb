module Decorators
  module V5
    class ResultSummaryDecorator
      attr_reader :assessment

      delegate :capital_summary,
               :disposable_income_summary,
               :gross_income_summary,
               to: :assessment

      def initialize(assessment, calculation_output)
        @assessment = assessment
        @calculation_output = calculation_output
      end

      def as_json
        {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            income_contribution: disposable_income_summary.income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(assessment).as_json,
          },
          gross_income: GrossIncomeResultDecorator.new(gross_income_summary).as_json,
          partner_gross_income:,
          disposable_income: DisposableIncomeResultDecorator.new(disposable_income_summary,
                                                                 gross_income_summary,
                                                                 partner_present: assessment.partner.present?).as_json,
          partner_disposable_income:,
          capital: CapitalResultDecorator.new(capital_summary,
                                              @calculation_output.capital_subtotals.applicant_capital_subtotals,
                                              @calculation_output.capital_subtotals.capital_contribution.to_f,
                                              @calculation_output.capital_subtotals.combined_assessed_capital.to_f).as_json,
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
                                            assessment.partner_gross_income_summary,
                                            partner_present: true).as_json
      end

      def partner_capital
        return unless assessment.partner

        CapitalResultDecorator.new(assessment.partner_capital_summary,
                                   @calculation_output.capital_subtotals&.partner_capital_subtotals,
                                   0, 0).as_json
      end
    end
  end
end
