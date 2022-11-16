FactoryBot.define do
  factory :partner do
    assessment
    date_of_birth { Faker::Date.between(from: 18.years.ago, to: 70.years.ago) }
    employed { Faker::Boolean }
  end
end
