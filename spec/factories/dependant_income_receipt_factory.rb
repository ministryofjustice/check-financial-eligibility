FactoryBot.define do
  factory :dependant_income_receipt do
    date_of_payment { Faker::Date.backward(60) }
    amount { Faker::Number.decimal(4, 2).to_f }
  end
end
