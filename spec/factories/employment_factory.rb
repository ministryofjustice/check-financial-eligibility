FactoryBot.define do
  factory :employment do
    assessment
    client_id { SecureRandom.uuid }
    sequence(:name) { |n| sprintf("Job %04d", n) }
  end

  trait :with_monthly_payments do
    after(:create) do |record|
      [Time.zone.today, 1.month.ago.to_date, 2.months.ago.to_date].each do |date|
        create :employment_payment, employment: record, date:, gross_income: 1500, gross_income_monthly_equiv: 1500
      end
    end
  end

  trait :with_irregular_payments do
    after(:create) do |record|
      [Time.zone.today, 32.days.ago.to_date, 64.days.ago.to_date].each do |date|
        create :employment_payment, employment: record, date:, gross_income: 1500, gross_income_monthly_equiv: 1500
      end
    end
  end
end
