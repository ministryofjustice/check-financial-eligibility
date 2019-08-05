FactoryBot.define do
  factory :outgoing do
    assessment
    outgoing_type { Outgoing.outgoing_types.values.sample }
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
