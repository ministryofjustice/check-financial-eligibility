FactoryBot.define do
  factory :non_liquid_asset do
    assessment
    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
  end
end
