FactoryBot.define do
  factory :dependant do
    assessment
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    relationship { Dependant.relationships.values.sample }
    monthly_income { rand(1...10_000.0).round(2).to_d(Float::DIG) }
    assets_value { 0.0 }

    trait :child_relative do
      relationship { :child_relative }
    end

    trait :adult_relative do
      relationship { :adult_relative }
    end

    trait :under15 do
      relationship { 'child_relative' }
      date_of_birth { Faker::Date.between(from: assessment.submission_date - 14.years, to: assessment.submission_date - 1.day) }
    end

    trait :aged15 do
      relationship { 'child_relative' }
      date_of_birth { Faker::Date.between(from: assessment.submission_date - 16.years, to: assessment.submission_date - 15.years) }
    end

    trait :aged16or17 do
      relationship { 'child_relative' }
      date_of_birth { Faker::Date.between(from: assessment.submission_date - 17.years, to: assessment.submission_date - 16.years) }
    end

    trait :over18 do
      date_of_birth { Faker::Date.between(from: assessment.submission_date - 65.years, to: assessment.submission_date - 18.years) }
    end
  end
end
