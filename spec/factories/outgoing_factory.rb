FactoryBot.define do
  factory childcare_outgoing, class_name: Outgoings::Childcare do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory housing_cost_outgoing, class_name: Outgoings::HousingCost do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory maintenance_outgoing, class_name: Outgoings::Maintentance do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
