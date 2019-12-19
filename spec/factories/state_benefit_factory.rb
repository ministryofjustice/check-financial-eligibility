FactoryBot.define do
  factory :state_benefit do
    gross_income_summary
    state_benefit_type

    name { nil }

    trait :with_monthly_payments do
      after(:create) do |record|
        [Date.today, 1.month.ago, 2.month.ago].each do |date|
          create :state_benefit_payment, state_benefit: record, amount: 75.0, payment_date: date
        end
      end
    end

    trait :with_weekly_payments do
      after(:create) do |record|
        dates = [0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77].map { |n| n.days.ago }
        dates.each do |date|
          create :state_benefit_payment, state_benefit: record, amount: 50.0, payment_date: date
        end
      end
    end
  end
end
