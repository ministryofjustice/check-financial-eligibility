module Decorators
  module V4
    class AssessmentDecorator
      # class aliases for V3
      ApplicantDecorator = ::Decorators::V3::ApplicantDecorator
      RemarksDecorator = ::Decorators::V3::RemarksDecorator

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
          result_summary: assessment_result_summary,
          assessment: assessment_details,
        }
      end

      def assessment_details
        {
          id: assessment.id,
          client_reference_id: assessment.client_reference_id,
          submission_date: assessment.submission_date,
          applicant: ApplicantDecorator.new(applicant).as_json,
          gross_income: GrossIncomeDecorator.new(@assessment).as_json,
          disposable_income: DisposableIncomeDecorator.new(@assessment).as_json,
          capital: CapitalDecorator.new(@assessment).as_json,
          remarks: RemarksDecorator.new(remarks, assessment).as_json,
        }
      end

      def assessment_result_summary
        assessment.criminal? ? CrimeResultSummaryDecorator.new(@assessment).as_json : ResultSummaryDecorator.new(@assessment).as_json
      end
    end
  end
end
