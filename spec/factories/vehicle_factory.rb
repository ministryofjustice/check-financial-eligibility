FactoryBot.define do
  factory :vehicle do
    assessment
    value { Faker::Number.decimal(4, 2) }
    loan_amount_outstanding { Faker::Number.decimal(4, 2) }
    date_of_purchase { Faker::Date.between(6.years.ago, 2.months.ago) }
    in_regular_use { Faker::Boolean.boolean }
  end
end
