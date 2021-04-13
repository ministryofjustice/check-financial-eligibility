FactoryBot.define do
  factory :gross_income_summary do
    assessment
    monthly_other_income { nil }

    trait :with_all_transaction_types do
      benefits_bank { 34.16 }
      friends_or_family_bank { 7.47 }
      maintenance_in_bank { 115.04 }
      property_or_lodger_bank { 483.47 }
      pension_bank { 27.4 }

      benefits_cash { 1038.07 }
      friends_or_family_cash { 255.34 }
      maintenance_in_cash { 1038.07 }
      property_or_lodger_cash { 0.0 }
      pension_cash { 0.0 }

      benefits_all_sources { 1072.23 }
      friends_or_family_all_sources { 262.81 }
      maintenance_in_all_sources { 1153.11 }
      property_or_lodger_all_sources { 483.47 }
      pension_all_sources { 27.4 }
    end

    trait :with_everything do
      after(:create) do |gross_income_summary|
        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary
      end
    end

    trait :with_eligibilities do
      after(:create) do |rec|
        rec.assessment.proceeding_type_codes.each do |ptc|
          create :gross_income_eligibility, gross_income_summary: rec, proceeding_type_code: ptc
        end
      end
    end

    trait :with_all_records do
      after(:create) do |gross_income_summary|
        benefits_in_cash = create :cash_transaction_category, name: 'benefits', operation: 'credit', gross_income_summary: gross_income_summary
        friends_or_family_in_cash = create :cash_transaction_category, name: 'friends_or_family', operation: 'credit', gross_income_summary: gross_income_summary
        maintenance_in_cash = create :cash_transaction_category, name: 'maintenance_in', operation: 'credit', gross_income_summary: gross_income_summary
        property_or_lodger_in_cash = create :cash_transaction_category, name: 'property_or_lodger', operation: 'credit', gross_income_summary: gross_income_summary
        pension_in_cash = create :cash_transaction_category, name: 'pension', operation: 'credit', gross_income_summary: gross_income_summary
        child_care_in_cash = create :cash_transaction_category, name: 'child_care', operation: 'debit', gross_income_summary: gross_income_summary
        maintenance_out_in_cash = create :cash_transaction_category, name: 'maintenance_out', operation: 'debit', gross_income_summary: gross_income_summary
        rent_or_mortgage_in_cash = create :cash_transaction_category, name: 'rent_or_mortgage', operation: 'debit', gross_income_summary: gross_income_summary
        legal_aid_in_cash = create :cash_transaction_category, name: 'legal_aid', operation: 'debit', gross_income_summary: gross_income_summary

        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary, name: 'friends_or_family', monthly_income: 100
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary, name: 'maintenance_in', monthly_income: 200
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary, name: 'property_or_lodger', monthly_income: 300
        create :other_income_source, :with_monthly_payments, gross_income_summary: gross_income_summary, name: 'pension', monthly_income: 400
        create :irregular_income_payment, gross_income_summary: gross_income_summary

        3.times do
          create :cash_transaction, cash_transaction_category: benefits_in_cash
          create :cash_transaction, cash_transaction_category: friends_or_family_in_cash
          create :cash_transaction, cash_transaction_category: maintenance_in_cash
          create :cash_transaction, cash_transaction_category: property_or_lodger_in_cash
          create :cash_transaction, cash_transaction_category: pension_in_cash
          create :cash_transaction, cash_transaction_category: child_care_in_cash
          create :cash_transaction, cash_transaction_category: maintenance_out_in_cash
          create :cash_transaction, cash_transaction_category: rent_or_mortgage_in_cash
          create :cash_transaction, cash_transaction_category: legal_aid_in_cash
        end
      end
    end

    trait :with_irregular_income_payments do
      after(:create) do |gross_income_summary|
        create :state_benefit, :with_monthly_payments, gross_income_summary: gross_income_summary
        create :irregular_income_payment, gross_income_summary: gross_income_summary
      end
    end
  end
end
