FactoryBot.define do
  factory :benefit_receipt do
    assessment
    benefit_name { BenefitReceipt.benefit_names.values.sample }
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
