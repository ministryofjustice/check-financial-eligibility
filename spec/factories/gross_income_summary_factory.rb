FactoryBot.define do
  factory :gross_income_summary do
    assessment
    monthly_other_income { nil }
  end
end
