FactoryBot.define do
  factory :state_benefit_type do
    sequence :label do |n|
      "benefit_type_#{n}"
    end
    # the name passed in is the same as the label in the state benefit type table except for seeded data
    name { label }
    dwp_code { [nil, ('A'..'Z').to_a.sample(2).join].sample }
    exclude_from_gross_income { [true, false].sample }

    trait :other do
      label { 'other' }
      name { 'Other state benefit type' }
      exclude_from_gross_income { false }
    end
  end
end
