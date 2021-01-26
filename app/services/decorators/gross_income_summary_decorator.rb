module Decorators
  class GrossIncomeSummaryDecorator
    attr_reader :record

    delegate :assessment, to: :record
    delegate :disposable_income_summary, to: :assessment

    def initialize(gross_income_summary)
      @record = gross_income_summary
    end

    def as_json # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil if record.nil?

      case record.version
      when CFEConstants::LATEST_ASSESSMENT_VERSION
        {
          summary: {
            total_gross_income: record.total_gross_income,
            upper_threshold: record.upper_threshold,
            assessment_result: record.assessment_result
          },
          student_loan: {
            monthly_equivalents: record.monthly_student_loan
          },
          other_income: OtherIncomeSourceDecorator.new(record).as_json
        }
      else
        {
          monthly_student_loan: record.monthly_student_loan,
          monthly_other_income: record.monthly_other_income,
          monthly_state_benefits: record.monthly_state_benefits,
          total_gross_income: record.total_gross_income,
          upper_threshold: record.upper_threshold,
          assessment_result: record.assessment_result,
          monthly_income_equivalents: MonthlyIncomeEquivalentDecorator.new(record).as_json,
          monthly_outgoing_equivalents: MonthlyOutgoingEquivalentDecorator.new(disposable_income_summary).as_json,
          state_benefits: record.state_benefits.map { |sb| StateBenefitDecorator.new(sb).as_json },
          other_income: record.other_income_sources.map { |oi| OtherIncomeSourceDecorator.new(oi).as_json },
          irregular_income: IrregularIncomePaymentsDecorator.new(record.irregular_income_payments).as_json
        }
      end
    end
  end
end
