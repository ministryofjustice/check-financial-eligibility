FactoryBot.define do
  factory :applicant do
    assessment
    date_of_birth { Faker::Date.between(18.years.ago, 65.years.ago) }
    involvement_type { 'Applicant' }
    has_partner_opponent { Faker::Boolean.boolean }
    receives_qualifying_benefit { Faker::Boolean.boolean }

    trait :with_qualifying_benefit do
      receives_qualifying_benefit { true }
    end

    trait :without_qualifying_benefit do
      receives_qualifying_benefit { false }
    end
  end
end
