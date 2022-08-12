module Decorators
  module V5
    class DisposableIncomeDecorator
      attr_reader :record, :categories

      def initialize(assessment)
        @assessment = assessment
        @summary = assessment.disposable_income_summary
        @categories = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
      end

      def as_json
        payload unless @summary.nil?
      end

    private

      def payload
        {
          monthly_equivalents:,
          childcare_allowance:,
          deductions:,
        }
      end

      def monthly_equivalents
        {
          all_sources: transactions(:all_sources),
          bank_transactions: transactions(:bank),
          cash_transactions: transactions(:cash),
        }
      end

      def transactions(source)
        {
          child_care: @summary.__send__("child_care_#{source}").to_f,
          rent_or_mortgage: @summary.__send__("rent_or_mortgage_#{source}").to_f,
          maintenance_out: @summary.__send__("maintenance_out_#{source}").to_f,
          legal_aid: @summary.__send__("legal_aid_#{source}").to_f,
        }
      end

      def childcare_allowance
        @summary.child_care_all_sources.to_f
      end

      def deductions
        {
          dependants_allowance: @summary.dependant_allowance.to_f,
          disregarded_state_benefits: Calculators::DisregardedStateBenefitsCalculator.call(@summary).to_f,
        }
      end
    end
  end
end
