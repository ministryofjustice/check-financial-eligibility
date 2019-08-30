FactoryBot.define do
  factory :non_liquid_capital_item do
    capital_summary
    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d }
  end

  factory :liquid_capital_item do
    capital_summary
    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d }

    trait :negative do
      value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_d * -1 }
    end
  end
end
