FactoryBot.define do
  factory :cash_transaction_category do
    gross_income_summary
    operation { nil }
    name { nil }

    trait :credit do
      operation { "credit" }
      name { CFEConstants::VALID_INCOME_CATEGORIES.sample }
    end
  end
end
