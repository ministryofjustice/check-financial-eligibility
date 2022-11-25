FactoryBot.define do
  factory :partner do
    assessment
    date_of_birth { Faker::Date.between(from: 18.years.ago, to: 70.years.ago) }
    employed { Faker::Boolean }

    trait :over_pensionable_age do
      date_of_birth { 61.years.ago.to_date }
    end

    trait :under_pensionable_age do
      date_of_birth { 59.years.ago.to_date }
    end

    after(:create) do |partner|
      create(:gross_income_summary, assessment: partner.assessment, type: "PartnerGrossIncomeSummary")
      create(:disposable_income_summary, assessment: partner.assessment, type: "PartnerDisposableIncomeSummary")
      create(:capital_summary, assessment: partner.assessment, type: "PartnerCapitalSummary")
    end
  end
end
