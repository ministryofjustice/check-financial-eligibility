FactoryBot.define do
  factory :childcare_outgoing, class: Outgoings::Childcare do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :housing_cost_outgoing, class: Outgoings::HousingCost do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    housing_cost_type { 'rent' }
  end

  factory :maintenance_outgoing, class: Outgoings::Maintenance do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end

  factory :legal_aid_outgoing, class: Outgoings::LegalAid do
    disposable_income_summary
    payment_date { Faker::Date.backward(days: 14) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
