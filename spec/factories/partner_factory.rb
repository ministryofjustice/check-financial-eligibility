FactoryBot.define do
  factory :partner do
    assessment
    date_of_birth { Faker::Date.between(from: 18.years.ago, to: 70.years.ago) }
    employed { Faker::Boolean }

    after(:create) do |partner|
      create(:gross_income_summary, assessment: partner.assessment, type: "PartnerGrossIncomeSummary")
      create(:disposable_income_summary, assessment: partner.assessment, type: "PartnerDisposableIncomeSummary")
    end
  end
end
