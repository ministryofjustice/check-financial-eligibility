module Calculators
  EmploymentIncomeResult = Struct.new :gross_employment_income, :benefits_in_kind, :employment_income_deductions,
                                      :fixed_employment_allowance, :tax, :national_insurance, keyword_init: true
end
