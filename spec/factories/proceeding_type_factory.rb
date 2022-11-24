FactoryBot.define do
  factory :proceeding_type do
    assessment

    sequence(:ccms_code) { |n| CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES[n % CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES.size] }
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

    trait :da003a do
      with_waived_thresholds
      ccms_code { "DA003" }
      client_involvement_type { "A" }
    end

    trait :se014z do
      with_unwaived_thresholds
      ccms_code { "SE014" }
    end
  end
end
