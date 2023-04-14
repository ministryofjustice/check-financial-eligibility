FactoryBot.define do
  factory :other_income_payment do
    other_income_source
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    client_id { SecureRandom.uuid }
  end
end
