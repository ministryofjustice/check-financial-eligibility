FactoryBot.define do
  factory :dependant_income_receipt do
    date_of_payment { Faker::Date.backward(days: 60) }
    amount { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
  end
end
