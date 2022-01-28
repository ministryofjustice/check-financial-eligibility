module Decorators
  module V3
    class AssessmentDecorator
      attr_reader :assessment

      delegate :applicant,
               :capital_summary,
               :gross_income_summary,
               :remarks,
               :disposable_income_summary, to: :assessment

      def initialize(assessment)
        @assessment = assessment
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
          assessment: {
            id: assessment.id,
            client_reference_id: assessment.client_reference_id,
            submission_date: assessment.submission_date,
            matter_proceeding_type: assessment.matter_proceeding_type,
            assessment_result: assessment.assessment_result,
            applicant: ApplicantDecorator.new(applicant).as_json,
            gross_income: GrossIncomeSummaryDecorator.new(gross_income_summary).as_json,
            disposable_income: DisposableIncomeSummaryDecorator.new(disposable_income_summary).as_json,
            capital: CapitalSummaryDecorator.new(capital_summary).as_json,
            remarks: RemarksDecorator.new(remarks, assessment).as_json
          }
        }
      end
    end
  end
end
