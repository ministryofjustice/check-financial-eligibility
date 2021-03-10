FactoryBot.define do
  factory :disposable_income_summary do
    assessment
    child_care_bank { 0.0 }
    maintenance_out_bank { 0.0 }
    legal_aid_bank { 0.0 }
    dependant_allowance { 0.0 }
    gross_housing_costs { 0.0 }
    rent_or_mortgage_bank { 0.0 }
    net_housing_costs { 0.0 }
    housing_benefit { 0.0 }
    total_outgoings_and_allowances { 0.0 }
    total_disposable_income { 0.0 }
    lower_threshold { 0.0 }
    upper_threshold { 0.0 }
    assessment_result { 'pending' }

    trait :with_v3 do
      assessment { create :assessment, :with_v3 }
    end

    trait :with_everything do
      after(:create) do |rec|
        [Date.current, 1.month.ago, 2.months.ago].each do |date|
          create :childcare_outgoing, disposable_income_summary: rec, payment_date: date, amount: 100
          create :maintenance_outgoing, disposable_income_summary: rec, payment_date: date, amount: 50
          create :housing_cost_outgoing, disposable_income_summary: rec, payment_date: date, amount: 125
          create :legal_aid_outgoing, disposable_income_summary: rec, payment_date: date, amount: 363
        end
      end
    end
  end
end
