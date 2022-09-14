FactoryBot.define do
  factory :regular_transaction do
    association :gross_income_summary
    category { "maintenance_in" }
    operation { "credit" }
    frequency { "four_weekly" }
    amount { "9.99" }
  end
end
