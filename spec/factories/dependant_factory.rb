FactoryBot.define do
  factory :dependant do
    assessment
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    relationship { Dependant.relationships.values.sample }
    monthly_income { rand(1...10_000.0).round(2) }
    assets_value { rand(1...10_000.0).round(2) }

    trait :child_relative do
      relationship { :child_relative }
    end

    trait :adult_relative do
      relationship { :adult_relative }
    end
  end
end
