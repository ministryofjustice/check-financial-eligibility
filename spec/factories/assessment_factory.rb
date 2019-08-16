FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| format('CLIENT-REF-%04d', n) }
    remote_ip { Faker::Internet.ip_v4_address }
    submission_date { Date.today }
    matter_proceeding_type { 'domestic_abuse' }

    transient do
      above_lower_threshold { false }
      below_lower_threshold { false }
      at_lower_threshold { false }
    end

    trait :with_applicant do
      applicant { create :applicant, :under_pensionable_age }
    end

    trait :with_applicant_over_pensionable_age do
      applicant { create :applicant, :over_pensionable_age }
    end

    trait :summarised_below_lower_threshold do
      transient do
        below_lower_threshold { true }
      end
    end

    trait :summarised_at_lower_threshold do
      transient do
        at_lower_threshold { true }
      end
    end

    trait :summarised_above_lower_threshold do
      transient do
        above_lower_threshold { true }
      end
    end

    after(:create) do |assessment, evaluator|
      if evaluator.below_lower_threshold
        create :capital_summary, :summarised, :below_lower_threshold, assessment: assessment
      elsif evaluator.at_lower_threshold
        create :capital_summary, :summarised, :at_lower_threshold, assessment: assessment
      elsif evaluator.above_lower_threshold
        create :capital_summary, :summarised, :above_lower_threshold, assessment: assessment
      else
        create :capital_summary, assessment: assessment
      end
    end
  end
end
