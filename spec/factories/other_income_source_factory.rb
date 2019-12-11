require Rails.root.join('spec/support/faker/other_income_source.rb')

FactoryBot.define do
  factory :other_income_source do
    gross_income_summary
    name { Faker::OtherIncomeSource.name }
    monthly_income { nil }
  end
end
