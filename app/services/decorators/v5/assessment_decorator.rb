module Decorators
  module V5
    class AssessmentDecorator
      attr_reader :assessment

      delegate :applicant,
               :capital_summary,
               :gross_income_summary,
               :remarks,
               :disposable_income_summary, to: :assessment

      def initialize(assessment, calculation_output)
        @assessment = assessment
        @calculation_output = calculation_output
      end

      def as_json
        payload
      end

    private

      def payload
        {
          version: assessment.version,
          timestamp: Time.current,
          success: true,
          result_summary: ResultSummaryDecorator.new(assessment, @calculation_output).as_json,
          assessment: assessment_details,
        }
      end

      def assessment_details
        {
          id: assessment.id,
          client_reference_id: assessment.client_reference_id,
          submission_date: assessment.submission_date,
          applicant: ApplicantDecorator.new(applicant).as_json,
          gross_income:,
          partner_gross_income:,
          disposable_income: DisposableIncomeDecorator.new(disposable_income_summary).as_json,
          partner_disposable_income:,
          capital: CapitalDecorator.new(capital_summary).as_json,
          partner_capital:,
          remarks: RemarksDecorator.new(remarks, assessment).as_json,
        }
      end

      def gross_income
        GrossIncomeDecorator.new(gross_income_summary,
                                 assessment.employments,
                                 @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals).as_json
      end

      def partner_gross_income
        return unless assessment.partner

        GrossIncomeDecorator.new(assessment.partner_gross_income_summary,
                                 assessment.partner_employments,
                                 @calculation_output.gross_income_subtotals.partner_gross_income_subtotals).as_json
      end

      def partner_disposable_income
        return unless assessment.partner

        DisposableIncomeDecorator.new(assessment.partner_disposable_income_summary).as_json
      end

      def partner_capital
        return unless assessment.partner

        CapitalDecorator.new(assessment.partner_capital_summary).as_json
      end
    end
  end
end
