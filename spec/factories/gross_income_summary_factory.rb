FactoryBot.define do
  factory :gross_income_summary do
    assessment
    monthly_other_income { nil }

    trait :with_everything do
      after(:create) do |gross_income_summary|
        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary
      end
    end

    trait :with_irregular_income_payments do
      after(:create) do |gross_income_summary|
        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :irregular_income_payment, gross_income_summary: gross_income_summary
      end
    end
  end
end
