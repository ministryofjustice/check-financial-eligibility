FactoryBot.define do
  factory :irregular_income_payment do
    gross_income_summary
    income_type { "student_loan" }
    frequency { "annual" }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
