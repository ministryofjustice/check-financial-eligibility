FactoryBot.define do
  factory :employment do
    gross_income_summary
    name { Faker::Lorem.unique.sentence }

    trait :with_earned_income do
      after(:create) do
        create :wage_payment, assessment: assessment
        create :benefit_in_kind, assessment: assessment
      end
    end
  end
end
