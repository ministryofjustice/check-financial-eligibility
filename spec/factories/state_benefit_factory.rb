FactoryBot.define do
  factory :state_benefit do
    gross_income_summary
    state_benefit_type

    name { nil }

    trait :with_monthly_payments do
      monthly_value { 88.3 }
      after(:create) do |record|
        [record.assessment.submission_date,
         record.assessment.submission_date - 1.month,
         record.assessment.submission_date - 2.months].each do |date|
          create :state_benefit_payment, state_benefit: record, amount: 88.30, payment_date: date, client_id: SecureRandom.uuid
        end
      end
    end

    trait :with_weekly_payments do
      after(:create) do |record|
        dates = [0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77].map { |n| record.assessment.submission_date - n.days }
        dates.each do |date|
          create :state_benefit_payment, state_benefit: record, amount: 50.0, payment_date: date, client_id: SecureRandom.uuid
        end
      end
    end
  end
end
