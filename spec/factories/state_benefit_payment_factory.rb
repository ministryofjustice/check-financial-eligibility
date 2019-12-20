FactoryBot.define do
  factory :state_benefit_payment do
    state_benefit

    payment_date { Date.today }
    amount { 123.45 }
  end
end
