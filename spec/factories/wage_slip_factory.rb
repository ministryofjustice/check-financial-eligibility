FactoryBot.define do
  factory :wage_slip do
    assessment
    payment_date { Faker::Date.backward(days: 14) }
    gross_pay { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    paye { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    nic { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
