FactoryBot.define do
  factory :capital_summary do
    assessment

    trait :pending do
      capital_assessment_result { 'pending' }
    end

    trait :eligible do
      capital_assessment_result { 'eligible' }
    end

    trait :not_eligible do
      capital_assessment_result { 'not_eligible' }
    end

    trait :contribution_required do
      capital_assessment_result { 'contribution_required' }
    end

    trait :below_lower_threshold do
      total_liquid { Faker::Number.between(from: 1.0, to: 2999.99).round(2) }
      total_capital { Faker::Number.between(from: 1.0, to: 2999.99).round(2) }
      assessed_capital { Faker::Number.between(from: 1.0, to: 2999.99).round(2) }
    end

    trait :at_lower_threshold do
      assessed_capital { 3_000 }
    end

    trait :above_lower_threshold do
      total_liquid { Faker::Number.between(from: 3_000.01, to: 999_999.99).round(2) }
      total_capital { Faker::Number.between(from: 3_000.01, to: 999_999.99).round(2) }
      assessed_capital { Faker::Number.between(from: 3_000.01, to: 999_999.99).round(2) }
    end

    trait :between_thresholds do
      total_liquid { Faker::Number.between(from: 3_000.01, to: 7_999.99).round(2) }
      total_capital { Faker::Number.between(from: 3_000.01, to: 7_999.99).round(2) }
      assessed_capital { Faker::Number.between(from: 3_000.01, to: 7_999.99).round(2) }
    end
  end
end
