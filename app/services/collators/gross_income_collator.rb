module Collators
  class GrossIncomeCollator < BaseWorkflowService
    include Transactions

    INCOME_CATEGORIES = CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)

    def call
      gross_income_summary.update!(populate_attrs)
    end

    private

    def populate_attrs
      attrs = default_attrs

      INCOME_CATEGORIES.each do |category|
        attrs[:"#{category}_bank"] = category == :benefits ? monthly_state_benefits : categorised_income[category].to_d
        attrs[:"#{category}_cash"] = monthly_transaction_amount_by(operation: :credit, category: category)
        attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
        attrs[:total_gross_income] += attrs[:"#{category}_all_sources"]
      end

      attrs
    end

    def default_attrs
      {
        total_gross_income: monthly_student_loan,
        monthly_student_loan: monthly_student_loan,
        student_loan: categorised_income[:student_loan],
        monthly_other_income: categorised_income[:total],
        monthly_state_benefits: monthly_state_benefits
      }
    end

    def monthly_state_benefits
      @monthly_state_benefits ||= Calculators::StateBenefitsCalculator.call(assessment)
    end

    def monthly_student_loan
      @monthly_student_loan ||= calculate_monthly_student_loan
    end

    def calculate_monthly_student_loan
      return 0.0 if categorised_income.key?(:student_loan)

      if gross_income_summary.irregular_income_payments.exists?
        total = 0
        gross_income_summary.irregular_income_payments.each do |payment|
          total += (payment.amount / 12)
        end
        total
      else
        0.0
      end
    end

    def categorised_income
      @categorised_income ||= categorise_income
    end

    def categorise_income
      result = Hash.new(0.0)
      gross_income_summary.other_income_sources.each do |source|
        monthly_income = source.calculate_monthly_income!
        result[source.name.to_sym] = monthly_income
        result[:total] += monthly_income
      end
      result
    end
  end
end
