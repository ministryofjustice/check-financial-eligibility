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
  end
end
