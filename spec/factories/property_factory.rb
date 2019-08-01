FactoryBot.define do
  factory :property do
    assessment

    value { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
    outstanding_mortgage { Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f }
    percentage_owned { Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f }
    main_home { [true, false].sample }
    shared_with_housing_assoc { [true, false].sample }

    trait :main_home do
      main_home { true }
    end

    trait :additional_property do
      main_home { false }
    end

    trait :shared_ownership do
      shared_with_housing_assoc { true }
    end

    trait :not_shared_ownership do
      shared_with_housing_assoc { false }
    end
  end
end
