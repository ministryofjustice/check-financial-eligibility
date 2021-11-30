FactoryBot.define do
  factory :employment do
    assessment
    sequence(:name) { |n| "Job #{n}" }
  end

  trait :with_monthly_payments do
    after(:create) do |record|
      [Date.current, 1.month.ago, 2.months.ago].each do |date|
        create :employment_payment, employment: record, date: date, gross_income: 1500
      end
    end
  end
end
