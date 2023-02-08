module Collators
  class GrossIncomeCollator
    include Transactions

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
      if @employments.any?
        @employments.each { |employment| Utilities::EmploymentIncomeMonthlyEquivalentCalculator.call(employment) }
        result = if @employments.count > 1
                   Calculators::MultipleEmploymentsCalculator.call(assessment: @assessment,
                                                                   employments: @employments)
                 else
                   Calculators::EmploymentIncomeCalculator.call(submission_date: @submission_date,
                                                                employment: @employments.first)
                 end
        @gross_income_summary.update!(gross_employment_income: result.gross_employment_income,
                                      benefits_in_kind: result.benefits_in_kind)
        @disposable_income_summary.update!(employment_income_deductions: result.employment_income_deductions,
                                           fixed_employment_allowance: result.fixed_employment_allowance,
                                           tax: result.tax,
                                           national_insurance: result.national_insurance)
        add_remarks if @employments.count > 1
      end
      @gross_income_summary.update!(populate_attrs)
    end

  private

    def add_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(:employment, :multiple_employments, employment_client_ids)
      @assessment.update!(remarks: my_remarks)
    end

    def employment_client_ids
      @employments.map(&:client_id)
    end

    def income_categories
      CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)
    end

    def populate_attrs
      attrs = default_attrs

      income_categories.each do |category|
        populate_income_attrs(attrs, category)
      end

      if @employments.count < 2
        attrs[:total_gross_income] += @gross_income_summary[:gross_employment_income]
      end

      attrs
    end

    def populate_income_attrs(attrs, category)
      attrs[:"#{category}_bank"] = category == :benefits ? monthly_state_benefits : categorised_income[category]
      attrs[:"#{category}_cash"] = monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :credit, category:)
      attrs[:"#{category}_all_sources"] = attrs[:"#{category}_bank"] + attrs[:"#{category}_cash"]
      attrs[:total_gross_income] += attrs[:"#{category}_all_sources"]
    end

    def default_attrs
      # setup initial values here, populate_income_attrs above adds the other income(s)
      # to the default start values here
      {
        total_gross_income: monthly_student_loan + monthly_unspecified_source,
        monthly_student_loan:,
        monthly_unspecified_source:,
        student_loan: categorised_income[:student_loan],
        unspecified_source: categorised_income[:unspecified_source],
        monthly_other_income: categorised_income[:total],
        monthly_state_benefits:,
      }
    end

    def monthly_state_benefits
      @monthly_state_benefits ||= Calculators::StateBenefitsCalculator.call(@gross_income_summary.state_benefits)
    end

    def monthly_student_loan
      @monthly_student_loan ||= calculate_monthly_student_loan
    end

    def calculate_monthly_student_loan
      return 0.0 if categorised_income.key?(:student_loan)

      @gross_income_summary.student_loan_payments.sum { monthly_equivalent_amount(_1) }
    end

    def monthly_unspecified_source
      @monthly_unspecified_source ||= calculate_monthly_unspecified_source
    end

    def calculate_monthly_unspecified_source
      return 0.0 if categorised_income.key?(:unspecified_source)

      @gross_income_summary.unspecified_source_payments.sum { monthly_equivalent_amount(_1) }
    end

    def categorised_income
      @categorised_income ||= categorise_income
    end

    def categorise_income
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
