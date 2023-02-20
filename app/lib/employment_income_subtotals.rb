class EmploymentIncomeSubtotals
  def initialize(values = Hash.new(0.0))
    @gross_employment_income = values[:gross_employment_income]
    @benefits_in_kind = values[:benefits_in_kind]
    @employment_income_deductions = values[:employment_income_deductions]
    @fixed_employment_allowance = values[:fixed_employment_allowance]
    @tax = values[:tax]
    @national_insurance = values[:national_insurance]
  end

  attr_reader :gross_employment_income,
              :benefits_in_kind,
              :employment_income_deductions,
              :fixed_employment_allowance,
              :tax,
              :national_insurance
end
