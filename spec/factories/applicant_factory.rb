FactoryBot.define do
  factory :applicant do
    date_of_birth { Faker::Date.birthday(18, 99) }
    involvement_type { 'applicant' }
    receives_qualifying_benefit { Faker::Boolean.boolean }
  end
end
