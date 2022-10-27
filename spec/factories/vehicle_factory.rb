FactoryBot.define do
  factory :vehicle do
    capital_summary
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    loan_amount_outstanding { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    date_of_purchase { Faker::Date.between(from: 6.years.ago, to: 2.months.ago) }
    in_regular_use { Faker::Boolean.boolean }
    subject_matter_of_dispute { Faker::Boolean.boolean }
  end
end
