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

    # use :with_child_dependants: 2 to create 2 children for the assessment
    transient do
      with_child_dependants { 0 }
    end

    trait :with_disposable_income_summary do
      after(:create) do |assessment|
        create :disposable_income_summary, assessment: assessment
      end
    end

    trait :with_capital_summary do
      after(:create) do |assessment|
        create :capital_summary, assessment: assessment
      end
    end

    trait :with_gross_income_summary do
      after(:create) do |assessment|
        create :gross_income_summary, assessment: assessment
      end
    end

    after(:create) do |assessment, evaluator|
      if evaluator.with_child_dependants > 0
        evaluator.with_child_dependants.times do
          create :dependant, :child_relative, assessment: assessment
        end
      end
    end
  end
end
