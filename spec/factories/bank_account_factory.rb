FactoryBot.define do
  factory :bank_account do
    assessment
    name { Faker::Bank.name }
    lowest_balance { Faker::Number.decimal(4, 2).to_f }
  end
end
