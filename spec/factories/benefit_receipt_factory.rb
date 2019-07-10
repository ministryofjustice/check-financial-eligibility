FactoryBot.define do
  factory :benefit_receipt do
    assessment
    benefit_name { BenefitReceipt.benefit_names.values.sample }
    payment_date { Faker::Date.backward(14) }
    amount { Faker::Number.decimal(3) }
  end
end
