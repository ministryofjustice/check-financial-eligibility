module Decorators
  class GrossIncomeSummaryDecorator
    attr_reader :record

    delegate :assessment, to: :record
    delegate :disposable_income_summary, to: :assessment

    def initialize(gross_income_summary)
      @record = gross_income_summary
    end

    def as_json
      return if record.nil?

      payload_v3
    end

    private

    def payload_v3 # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        summary: {
          total_gross_income: record.total_gross_income,
          upper_threshold: record.upper_threshold,
          assessment_result: record.assessment_result
        },
        irregular_income: {
          monthly_equivalents: {
            student_loan: record.monthly_student_loan
          }
        },
        state_benefits: {
          monthly_equivalents: {
            all_sources: record.benefits_all_sources,
            cash_transactions: record.benefits_cash,
            bank_transactions: record.state_benefits.map { |sb| StateBenefitDecorator.new(record, sb).as_json }
          }
        },
        other_income: OtherIncomeSourceDecorator.new(record).as_json
      }
    end
  end
end
