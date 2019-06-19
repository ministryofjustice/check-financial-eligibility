FactoryBot.define do
  factory :property do
    assessment

    value { Faker::Number.decimal(4, 2) }
    outstanding_mortgage { Faker::Number.decimal(4, 2) }
    percentage_owned { Faker::Number.decimal(1, 2) }
    main_home { [true, false].sample }
    shared_with_housing_assoc { [true, false].sample }
  end
end
