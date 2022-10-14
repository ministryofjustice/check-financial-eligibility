module Collators
  class GrossIncomeCollator < BaseWorkflowService
    include Transactions

    def call
      if assessment.employments.any?
        assessment.employments.each { |employment| Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(employment) }
        Calculators::EmploymentIncomeCalculator.call(assessment)
      end
      gross_income_summary.update!(populate_attrs)
    end

  private

    def income_categories
      CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
    end

    def populate_attrs
      attrs = default_attrs

      income_categories.each do |category|
        populate_income_attrs(attrs, category)
      end

      if assessment.employments.count < 2
        attrs[:total_gross_income] += gross_income_summary[:gross_employment_income]
      end

      attrs
    end

    def populate_income_attrs(attrs, category)
      attrs[:"#{category}_bank"] = category == :benefits ? monthly_state_benefits : categorised_income[category].to_d
      attrs[:"#{category}_cash"] = monthly_cash_transaction_amount_by(operation: :credit, category:)
      attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
      attrs[:total_gross_income] += attrs[:"#{category}_all_sources"]
    end

    def default_attrs
      # setup initial values here, populate_income_attrs above adds the other income(s)
      # to the default start values here
      {
        total_gross_income: monthly_student_loan + monthly_unspecified_source_income,
        monthly_student_loan:,
        monthly_unspecified_source_income:,
        student_loan: categorised_income[:student_loan],
        unspecified_source_income: categorised_income[:unspecified_source_income],
        monthly_other_income: categorised_income[:total],
        monthly_state_benefits:,
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

      if gross_income_summary.irregular_income_payments.student_loan.exists?
        total = 0
        gross_income_summary.irregular_income_payments.student_loan.each do |payment|
          total += (payment.amount / irregular_payment_divisor(payment))
        end
        total
      else
        0.0
      end
    end

    def monthly_unspecified_source_income
      @monthly_unspecified_source_income ||= calculate_monthly_unspecified_source_income
    end

    def calculate_monthly_unspecified_source_income
      return 0.0 if categorised_income.key?(:unspecified_source_income)

      if gross_income_summary.irregular_income_payments.unspecified.exists?
        total = 0
        gross_income_summary.irregular_income_payments.unspecified.each do |payment|
          total += (payment.amount / irregular_payment_divisor(payment))
        end
        total
      else
        0.0
      end
    end

    def irregular_payment_divisor(irregular_income_payment)
      case irregular_income_payment.frequency
      when CFEConstants::ANNUAL_FREQUENCY
        12
      when CFEConstants::QUARTERLY_FREQUENCY
        3
      else
        raise "Unprocessable irregular income payment frequency: #{irregular_income_payment.frequency}"
      end
    end

    def categorised_income
      @categorised_income ||= categorise_income
    end

    def categorise_income
      result = Hash.new(0.0)
      gross_income_summary.other_income_sources.each do |source|
        monthly_income = BigDecimal(source.calculate_monthly_income!, Float::DIG)
        result[source.name.to_sym] = monthly_income
        result[:total] += monthly_income
      end
      result
    end
  end
end
