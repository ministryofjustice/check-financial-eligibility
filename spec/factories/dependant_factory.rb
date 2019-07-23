FactoryBot.define do
  factory :dependant do
    date_of_birth { Faker::Date.birthday }
    in_full_time_education { [true, false].sample }
    dependant_income_receipts { build_list(:dependant_income_receipt, 3) }
    assessment
  end
end
