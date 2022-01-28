module Decorators
  module V3
    class GrossIncomeSummaryDecorator
      include Transactions

      attr_reader :record, :categories

      delegate :assessment, to: :record
      delegate :disposable_income_summary, to: :assessment

      def initialize(gross_income_summary)
        @record = gross_income_summary
        @categories = income_categories_excluding_benefits
      end

      def as_json
        payload unless record.nil?
      end

    private

      def income_categories_excluding_benefits
        CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym) - [:benefits]
      end

      def payload
        {
          summary: {
            total_gross_income: record.total_gross_income,
            upper_threshold: record.eligibilities.first.upper_threshold,
            assessment_result: record.summarized_assessment_result
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
              bank_transactions: record.state_benefits.map { |sb| StateBenefitDecorator.new(sb).as_json }
            }
          },
          other_income: {
            monthly_equivalents: all_transaction_types
          }
        }
      end
    end
  end
end
