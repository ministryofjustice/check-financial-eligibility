FactoryBot.define do
  factory :outgoing do
    assessment
    outgoing_type { Outgoing.outgoing_types.values.sample }
    payment_date { Faker::Date.backward(14) }
    amount { Faker::Number.decimal(3) }
  end
end
