module Decorators
  module V5
    class GrossIncomeDecorator
      include Transactions

      def initialize(assessment)
        @assessment = assessment
        @categories = income_categories_excluding_benefits
      end

      def as_json
        {
          employment_income: employment_incomes,
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

      def employment_incomes
        @assessment.employments.map { |employment| employment_income(employment) }
      end

      def employment_income(employment)
        {
          name: employment.name,
          payments: employment_payments(employment)
        }
      end

      def employment_payments(employment)
        employment.employment_payments.map { |payment| employment_payment(payment) }
      end

      def employment_payment(payment)
        {
          date: payment.date.strftime('%Y-%m-%d'),
          gross: payment.gross_income.to_f,
          benefits_in_kind: payment.benefits_in_kind.to_f,
          tax: payment.tax.to_f,
          national_insurance: payment.national_insurance.to_f,
          net_employment_income: net_employment_income(payment).to_f
        }
      end

      def net_employment_income(payment)
        payment.gross_income + payment.benefits_in_kind + payment.tax + payment.national_insurance
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
