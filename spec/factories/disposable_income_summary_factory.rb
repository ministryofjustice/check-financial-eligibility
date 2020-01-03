FactoryBot.define do
  factory :disposable_income_summary do
    assessment
    monthly_childcare { 0.0 }
    monthly_dependant_allowance { 0.0 }
    monthly_housing_costs { 0.0 }
    total_monthly_outgoings { 0.0 }
    total_disposable_income { 0.0 }
    lower_threshold { 0.0 }
    upper_threshold { 0.0 }
    assessment_result { 'pending' }
  end
end
