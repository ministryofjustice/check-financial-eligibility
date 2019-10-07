FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| format('CLIENT-REF-%<number>04d', number: n) }
    remote_ip { Faker::Internet.ip_v4_address }
    submission_date { Date.today }
    matter_proceeding_type { 'domestic_abuse' }

    trait :with_applicant do
      applicant { create :applicant, :under_pensionable_age }
    end

    trait :with_applicant_over_pensionable_age do
      applicant { create :applicant, :over_pensionable_age }
    end

    after(:create) do |assessment, _evaluator|
      create :capital_summary, assessment: assessment
    end
  end
end
