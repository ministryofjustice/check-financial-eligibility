FactoryBot.define do
  factory :property do
    assessment

    value { Faker::Number.decimal(4, 2).to_f }
    outstanding_mortgage { Faker::Number.decimal(4, 2).to_f }
    percentage_owned { Faker::Number.decimal(1, 2).to_f }
    main_home { [true, false].sample }
    shared_with_housing_assoc { [true, false].sample }
  end
end
