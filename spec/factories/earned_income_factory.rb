FactoryBot.define do
  factory :wage_payment do
    employment
    date { Faker::Date.backward }
    gross_payment { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d }
  end

  factory :benefit_in_kind do
    employment
    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d }
  end
end
