FactoryBot.define do
  factory :employment_payment do
    employment
    date { Faker::Date.between(from: 4.months.ago, to: Time.zone.today) }
    gross_income { Faker::Number.between(from: 2022.35, to: 3096.52).round(2) }
    benefits_in_kind { 0.0 }
    tax { (gross_income * 0.33).round(2) * -1 }
    national_insurance { (gross_income * 0.1).round(2) * -1 }
  end
end
