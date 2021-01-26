module Collators
  class GrossIncomeCollator < BaseWorkflowService
    OPERATION = :credit
    INCOME_CATEGORIES = CFEConstants::VALID_INCOME_CATEGORIES.map(&:to_sym)

    def call
      params = default_params

      case assessment.version
      when CFEConstants::LATEST_ASSESSMENT_VERSION
        add_transactions_v3 params
      else
        add_transactions_v2 params
      end

      gross_income_summary.send(:update!, params)
    end

    private

    def add_transactions_v2(params)
      INCOME_CATEGORIES.each { |category| params[category] = categorised_income[category] if category != :benefits }
      params[:total_gross_income] += categorised_income[:total] + monthly_state_benefits
    end

    def add_transactions_v3(params)
      INCOME_CATEGORIES.each do |category|
        params[:"#{category}_bank"] = category == :benefits ? monthly_state_benefits : categorised_income[category].to_d
        params[:"#{category}_cash"] = monthly_transaction_amount_by(operation: OPERATION, name: category)
        params[:"#{category}_all_sources"] = params[:"#{category}_bank"] + params[:"#{category}_cash"]
        params[:total_gross_income] += params[:"#{category}_all_sources"]
      end
    end

    def default_params
      {
        upper_threshold: upper_threshold,
        total_gross_income: monthly_student_loan,
        assessment_result: 'summarised',
        monthly_student_loan: monthly_student_loan,
        student_loan: categorised_income[:student_loan],
        monthly_other_income: categorised_income[:total],
        monthly_state_benefits: monthly_state_benefits
      }
    end

    def monthly_transaction_amount_by(operation:, name:)
      transactions = cash_transactions_find_by(operation: operation, name: name)
      return 0.0 if transactions.empty?

      transactions.average(:amount).round(2)
    end

    def cash_transactions_find_by(operation:, name:)
      category = gross_income_summary.cash_transaction_categories.find_by(operation: operation, name: name)
      CashTransaction.where(cash_transaction_category_id: category&.id)
    end

    def upper_threshold
      return infinite_threshold if assessment.matter_proceeding_type == 'domestic_abuse' && assessment.applicant.involvement_type == 'applicant'

      Threshold.value_for(:gross_income_upper, at: assessment.submission_date) + dependant_increase
    end

    def infinite_threshold
      @infinite_threshold ||= Threshold.value_for(:infinite_gross_income_upper, at: assessment.submission_date)
    end

    def dependant_increase_starts_after
      @dependant_increase_starts_after ||= Threshold.value_for(:dependant_increase_starts_after, at: assessment.submission_date)
    end

    def dependant_step
      @dependant_step ||= Threshold.value_for(:dependant_step, at: assessment.submission_date)
    end

    def number_of_child_dependants
      assessment.dependants.where(relationship: 'child_relative').count
    end

    def dependant_increase
      return 0 unless number_of_child_dependants > dependant_increase_starts_after

      (number_of_child_dependants - dependant_increase_starts_after) * dependant_step
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
