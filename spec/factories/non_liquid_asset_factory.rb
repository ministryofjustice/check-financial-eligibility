FactoryBot.define do
  factory :non_liquid_asset do
    assessment
    description { Faker::Lorem.unique.sentence }
    value { Faker::Number.decimal(4, 2).to_f }
  end
end
