FactoryBot.define do
  factory :wage_slip do
    assessment
    payment_date { Faker::Date.backward(14) }
    gross_pay { Faker::Number.decimal(5) }
    paye { Faker::Number.decimal(4) }
    nic { Faker::Number.decimal(3) }
  end
end
