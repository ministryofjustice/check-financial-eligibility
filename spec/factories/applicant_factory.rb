FactoryBot.define do
  factory :applicant do
    assessment
    date_of_birth { Faker::Date.between(18.years.ago, 70.years.ago) }
    involvement_type { 'applicant' }
    has_partner_opponent { false }
    receives_qualifying_benefit { false }

    trait :with_qualifying_benfits do
      receives_qualifying_benefit { true }
    end
  end
end
