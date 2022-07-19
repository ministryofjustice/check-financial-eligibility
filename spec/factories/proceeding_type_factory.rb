FactoryBot.define do
  factory :proceeding_type do
    assessment

    sequence(:ccms_code) { |n| ProceedingTypeThreshold.valid_ccms_codes[n % ProceedingTypeThreshold.valid_ccms_codes.size] }
    client_involvement_type { CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES.sample }

    trait :with_invalid_ccms_code do
      ccms_code { "XX1234" }
    end

    trait :with_invalid_client_involvement_type do
      client_involvement_type { "X" }
    end

    trait :with_waived_thresholds do
      ccms_code { "DA001" }
      client_involvement_type { "A" }
      gross_income_upper_threshold { 999_999_999_999.0 }
      disposable_income_upper_threshold { 999_999_999_999.0 }
      capital_upper_threshold { 999_999_999_999.0 }
    end

    trait :with_unwaived_thresholds do
      ccms_code { "DA004" }
      client_involvement_type { "Z" }
      gross_income_upper_threshold { 2657.0 }
      disposable_income_upper_threshold { 733.0 }
      capital_upper_threshold { 8_000.0 }
    end
  end
end
