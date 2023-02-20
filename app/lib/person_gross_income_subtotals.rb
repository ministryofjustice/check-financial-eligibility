class PersonGrossIncomeSubtotals
  def initialize(gross_income_components = Hash.new(0.0))
    @gross_income_components = gross_income_components
    @regular_income_categories = gross_income_components.fetch(:regular_income_categories, [])
  end

  def total_gross_income
    @gross_income_components[:total_gross_income]
  end

  def monthly_student_loan
    @gross_income_components[:monthly_student_loan]
  end

  def monthly_unspecified_source
    @gross_income_components[:monthly_unspecified_source]
  end

  def employment_income_subtotals
    @employment_income_subtotals ||= @gross_income_components.fetch(:employment_income_subtotals, EmploymentIncomeSubtotals.new)
  end

  def monthly_regular_incomes(income_type, income_category)
    category_data = regular_income_categories.find { _1.category == income_category }
    return 0 unless category_data

    category_data.send(income_type)
  end

private

  def regular_income_categories
    @gross_income_components.fetch(:regular_income_categories, [])
  end
end
