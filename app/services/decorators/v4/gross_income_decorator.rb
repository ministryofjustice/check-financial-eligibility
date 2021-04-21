module Decorators
  module V4
    class GrossIncomeDecorator
      include Transactions

      def initialize(assessment)
        @assessment = assessment
        @categories = income_categories_excluding_benefits
      end

      def as_json
        {
          irregular_income: irregular_income,
          state_benefits: state_benefits,
          other_income: other_income
        }
      end

      private

      def income_categories_excluding_benefits
        CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym) - [:benefits]
      end

      def summary
        @summary ||= @assessment.gross_income_summary
      end

      def irregular_income
        {
          monthly_equivalents:
            {
              student_loan: summary.monthly_student_loan.to_f
            }
        }
      end

      def other_income
        {
          monthly_equivalents: {
            all_sources: transactions(:all_sources),
            bank_transactions: transactions(:bank),
            cash_transactions: transactions(:cash)
          }
        }
      end

      def transactions(source)
        {
          friends_or_family: summary.__send__("friends_or_family_#{source}").to_f,
          maintenance_in: summary.__send__("maintenance_in_#{source}").to_f,
          property_or_lodger: summary.__send__("property_or_lodger_#{source}").to_f,
          pension: summary.__send__("pension_#{source}").to_f
        }
      end

      def state_benefits
        {
          monthly_equivalents: {
            all_sources: summary.benefits_all_sources.to_f,
            cash_transactions: summary.benefits_cash.to_f,
            bank_transactions: summary.state_benefits.map { |sb| StateBenefitDecorator.new(sb).as_json }
          }
        }
      end
    end
  end
end
