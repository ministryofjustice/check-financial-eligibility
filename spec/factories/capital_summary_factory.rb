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
      total_liquid { 350 }
      total_capital { 350 }
      assessed_capital { 350 }
    end

    trait :at_lower_threshold do
      assessed_capital { 3_000 }
    end

    trait :above_lower_threshold do
      total_liquid { 3_000.01 }
      total_capital { 3_000.01 }
      assessed_capital { 3_000.01 }
    end
  end
end
