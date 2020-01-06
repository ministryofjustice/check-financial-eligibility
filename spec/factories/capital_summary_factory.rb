FactoryBot.define do
  factory :capital_summary do
    assessment

    trait :pending do
      assessment_result { 'pending' }
    end

    trait 'summarised' do
      assessment_result { 'summarised' }
      total_liquid { Faker::Number.decimal }
      total_non_liquid { Faker::Number.decimal }
      total_vehicle { Faker::Number.decimal }
      total_mortgage_allowance { Faker::Number.decimal }
      total_property { Faker::Number.decimal }
      pensioner_capital_disregard { Faker::Number.decimal }
      total_capital { Faker::Number.decimal }
      assessed_capital { Faker::Number.decimal }
      lower_threshold { Faker::Number.between(from: 1.0, to: 3_000).round(2) }
      upper_threshold { Faker::Number.between(from: 3_001, to: 10_000).round(2) }
    end

    trait :below_lower_threshold do
      assessed_capital { Faker::Number.between(from: 1.0, to: 3_000).round(2) }
      lower_threshold { Faker::Number.between(from: 4_000, to: 5_000).round(2) }
      upper_threshold { Faker::Number.between(from: 6_000, to: 10_000).round(2) }
    end

    trait :between_thresholds do
      assessed_capital { Faker::Number.between(from: 4_000, to: 5_000).round(2) }
      lower_threshold { Faker::Number.between(from: 1.0, to: 3_000).round(2) }
      upper_threshold { Faker::Number.between(from: 6_000, to: 10_000).round(2) }
    end

    trait :above_upper_threshold do
      assessed_capital { Faker::Number.between(from: 11_000, to: 30_000).round(2) }
      lower_threshold { Faker::Number.between(from: 1.0, to: 3_000).round(2) }
      upper_threshold { Faker::Number.between(from: 6_000, to: 10_000).round(2) }
    end
  end
end
