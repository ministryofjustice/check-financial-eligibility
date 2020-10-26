FactoryBot.define do
  factory :state_benefit_payment do
    state_benefit

    payment_date { Date.today }
    amount { 123.45 }
    flags { nil }

    trait :with_multi_benefit_flag do
      flags { ['multi_benefit'] }
    end
  end
end
