require Rails.root.join('spec/support/faker/other_income_source.rb')

FactoryBot.define do
  factory :other_income_source do
    gross_income_summary
    name { OtherIncomeSource::VALID_INCOME_SOURCES.sample }
    monthly_income { nil }

    # TODO: remove when irregular income handles student loan and not other income
    trait :payments_without_student_loan do
      name { (OtherIncomeSource::VALID_INCOME_SOURCES - ['student_loan']).sample }
      after(:create) do |record|
        [Date.today, 1.month.ago, 2.month.ago].each do |date|
          create :other_income_payment, other_income_source: record, amount: 75.0, payment_date: date, client_id: SecureRandom.uuid
        end
      end
    end

    trait :with_monthly_payments do
      after(:create) do |record|
        [Date.today, 1.month.ago, 2.month.ago].each do |date|
          create :other_income_payment, other_income_source: record, amount: 75.0, payment_date: date, client_id: SecureRandom.uuid
        end
      end
    end
  end
end
