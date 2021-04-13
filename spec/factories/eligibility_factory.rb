FactoryBot.define do
  factory :capital_eligibility, class: Eligibility::Capital do
    capital_summary
    proceeding_type_code { 'DA001' }
    lower_threshold { 3_000.0 }
    upper_threshold { 999_999_999_999.0 }
    assessment_result { 'pending' }
  end

  factory :gross_income_eligibility, class: Eligibility::GrossIncome do
    gross_income_summary
    proceeding_type_code { 'DA001' }
    upper_threshold { 999_999_999_999.0 }
    assessment_result { 'pending' }
  end

  factory :disposable_income_eligibility, class: Eligibility::DisposableIncome do
    disposable_income_summary
    proceeding_type_code { 'DA001' }
    lower_threshold { 315.0 }
    upper_threshold { 999_999_999_999.0 }
    assessment_result { 'pending' }
  end
end
