module Collators
  class GrossIncomeCollator
    class << self
      def call(assessment:, submission_date:, employments:, disposable_income_summary:, gross_income_summary:)
        new(assessment:, submission_date:, employments:, disposable_income_summary:, gross_income_summary:).call
      end
    end

    def initialize(assessment:, submission_date:, employments:, disposable_income_summary:, gross_income_summary:)
      @assessment = assessment
      @submission_date = submission_date
      @employments = employments
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
    end

    def call
      employment_income_subtotals = if @employments.any?
                                      derive_employment_income_subtotals
                                    else
                                      EmploymentIncomeSubtotals.new(gross_employment_income: 0, benefits_in_kind: 0)
                                    end
      perform_collation(employment_income_subtotals)
    end

  private

    def derive_employment_income_subtotals
      @employments.each { |employment| Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(employment) }
      result = if @employments.count > 1
                 Calculators::MultipleEmploymentsCalculator.call(assessment: @assessment,
                                                                 employments: @employments)
               else
                 Calculators::EmploymentIncomeCalculator.call(submission_date: @submission_date,
                                                              employment: @employments.first)
               end

      @disposable_income_summary.update!(employment_income_deductions: result.employment_income_deductions,
                                         fixed_employment_allowance: result.fixed_employment_allowance,
                                         tax: result.tax,
                                         national_insurance: result.national_insurance)
      add_remarks if @employments.count > 1

      result
    end

    def add_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(:employment, :multiple_employments, @employments.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end

    def income_categories
      CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
    end

    def perform_collation(employment_income_subtotals)
      regular_income_categories = income_categories.map do |category|
        calculate_category_subtotals(category)
      end

      total_gross_income = employment_income_subtotals.gross_employment_income +
        regular_income_categories.sum(&:all_sources) +
        monthly_student_loan +
        monthly_unspecified_source

      PersonGrossIncomeSubtotals.new(
        total_gross_income:,
        monthly_student_loan:,
        monthly_unspecified_source:,
        regular_income_categories:,
        employment_income_subtotals:,
      )
    end

    def calculate_category_subtotals(category)
      bank = if category == :benefits
               monthly_state_benefits
             else
               categorised_bank_transactions[category]
             end

      cash = Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary: @gross_income_summary, operation: :credit, category:)
      regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary: @gross_income_summary, operation: :credit, category:)
      GrossIncomeCategorySubtotals.new(
        category: category.to_sym,
        bank:,
        cash:,
        regular:,
        all_sources: bank + cash + regular,
      )
    end

    def monthly_state_benefits
      @monthly_state_benefits ||= Calculators::StateBenefitsCalculator.call(@gross_income_summary.state_benefits)
    end

    def monthly_student_loan
      @monthly_student_loan ||= @gross_income_summary.student_loan_payments.sum { monthly_equivalent_amount(_1) }
    end

    def monthly_unspecified_source
      @monthly_unspecified_source ||= @gross_income_summary.unspecified_source_payments.sum { monthly_equivalent_amount(_1) }
    end

    def categorised_bank_transactions
      @categorised_bank_transactions ||= categorise_bank_transaction
    end

    def categorise_bank_transaction
      result = Hash.new(0.0)
      @gross_income_summary.other_income_sources.each do |source|
        monthly_income = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: @gross_income_summary.assessment.assessment_errors,
          collection: source.other_income_payments,
        )

        # TODO: Stop persisting this
        source.update!(monthly_income:)

        formatted = BigDecimal(monthly_income, Float::DIG)
        result[source.name.to_sym] = formatted
        result[:total] += formatted
      end

      result
    end

    def monthly_equivalent_amount(payment)
      payment.amount / MONTHS_PER_PERIOD.fetch(payment.frequency)
    end

    MONTHS_PER_PERIOD = {
      CFEConstants::ANNUAL_FREQUENCY => 12,
      CFEConstants::QUARTERLY_FREQUENCY => 3,
      CFEConstants::MONTHLY_FREQUENCY => 1,
    }.freeze
  end
end
