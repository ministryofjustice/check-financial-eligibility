FactoryBot.define do
  factory :dependent do
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    assessment
  end
end
