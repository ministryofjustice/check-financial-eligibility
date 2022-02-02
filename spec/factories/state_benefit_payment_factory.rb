FactoryBot.define do
  factory :state_benefit_payment do
    state_benefit

    payment_date { Date.current }
    amount { 123.45 }
    flags { nil }

    trait :with_multi_benefit_flag do
      flags { %w[multi_benefit] }
    end
  end
end
