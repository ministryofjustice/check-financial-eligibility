FactoryBot.define do
  factory :dependant do
    assessment
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    relationship { Dependant.relationships.keys.sample }
    monthly_income { rand(1...10_000.0).round(2) }
    assets_value { rand(1...10_000.0).round(2) }
  end
end
