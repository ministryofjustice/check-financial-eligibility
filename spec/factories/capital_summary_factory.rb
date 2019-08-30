FactoryBot.define do
  factory :capital_summary do
    assessment

    trait :pending do
      capital_assessment_result { 'pending' }
    end

    trait 'summarised' do
      capital_assessment_result { 'summarised' }
      lower_threshold { 3_000 }
      upper_threshold { 8_000 }
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
  end
end
