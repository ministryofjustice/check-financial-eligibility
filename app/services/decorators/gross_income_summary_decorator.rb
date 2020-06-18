module Decorators
  class GrossIncomeSummaryDecorator
    attr_reader :record

    delegate :assessment, to: :record
    delegate :disposable_income_summary, to: :assessment

    def initialize(gross_income_summary)
      @record = gross_income_summary
    end

    def as_json # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil if @record.nil?

      monthly_student_loan.merge(
        {
          monthly_other_income: @record.monthly_other_income,
          monthly_state_benefits: @record.monthly_state_benefits,
          total_gross_income: @record.total_gross_income,
          upper_threshold: @record.upper_threshold,
          assessment_result: @record.assessment_result,
          monthly_income_equivalents: MonthlyIncomeEquivalentDecorator.new(@record).as_json,
          monthly_outgoing_equivalents: MonthlyOutgoingEquivalentDecorator.new(disposable_income_summary).as_json,
          state_benefits: @record.state_benefits.map { |sb| StateBenefitDecorator.new(sb).as_json },
          other_income: @record.other_income_sources.map { |oi| OtherIncomeSourceDecorator.new(oi).as_json },
          irregular_income: IrregularIncomePaymentsDecorator.new(@record.irregular_income_payments).as_json
        }
      )
    end

    private

    # TODO: remove this method and add monthly_student_loan key/value to the above json response when other income no longer includes student loan
    def monthly_student_loan
      @record.other_income_sources.each do |source|
        return {} if source.student_payment?
      end
      return {} unless @record.irregular_income_payments.present?

      {
        monthly_student_loan: @record.monthly_student_loan
      }
    end
  end
end
