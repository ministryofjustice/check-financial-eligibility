FactoryBot.define do
  factory :employment do
    assessment
    client_id { SecureRandom.uuid }
    sequence(:name) { |n| sprintf("Job %04d", n) }

    transient do
      gross_monthly_income { 1500 }
    end

    trait :with_monthly_payments do
      after(:create) do |record, evaluator|
        [record.assessment.submission_date,
         record.assessment.submission_date - 1.month,
         record.assessment.submission_date - 2.months].each do |date|
          create :employment_payment, employment: record, date:,
                                      gross_income: evaluator.gross_monthly_income
        end
      end
    end

    factory :partner_employment do
    end
  end

  trait :with_irregular_payments do
    after(:create) do |record|
      [record.assessment.submission_date,
       record.assessment.submission_date - 32.days,
       record.assessment.submission_date - 64.days].each do |date|
        create :employment_payment, employment: record, date:, gross_income: 1500, gross_income_monthly_equiv: 1500
      end
    end
  end
end
