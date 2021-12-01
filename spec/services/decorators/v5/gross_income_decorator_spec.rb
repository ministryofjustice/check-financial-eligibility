require 'rails_helper'

module Decorators
  module V5
    RSpec.describe GrossIncomeDecorator do
      let(:assessment) { create :assessment }
      let(:summary) do
        create :gross_income_summary,
               assessment: assessment,
               monthly_student_loan: 250,
               benefits_all_sources: 1_322.6,
               benefits_bank: 1_322.6,
               maintenance_in_all_sources: 350,
               maintenance_in_bank: 200,
               maintenance_in_cash: 150,
               friends_or_family_all_sources: 50,
               friends_or_family_cash: 50,
               property_or_lodger_all_sources: 250,
               property_or_lodger_bank: 250
      end
      let(:employment1) { create :employment, :with_monthly_payments, assessment: assessment }
      let(:employment2) { create :employment, :with_monthly_payments, assessment: assessment }
      let(:universal_credit) { create :state_benefit_type, :universal_credit }
      let(:child_benefit) { create :state_benefit_type, :child_benefit }
      let(:expected_results) do
        {
          employment_income: [
            {
              name: employment1.name,
              payments: [
                {
                  date: Date.current.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                },
                {
                  date: 1.month.ago.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                },
                {
                  date: 2.months.ago.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                }
              ]
            },
            {
              name: employment2.name,
              payments: [
                {
                  date: Date.current.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                },
                {
                  date: 1.month.ago.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                },
                {
                  date: 2.months.ago.strftime('%Y-%m-%d'),
                  benefits_in_kind: 0.0,
                  gross: 1500.0,
                  tax: -495.0,
                  national_insurance: -150.0,
                  net_employment_income: 855.0
                }
              ]
            }
          ],
          irregular_income: {
            monthly_equivalents:
              {
                student_loan: 250.0
              }
          },
          state_benefits: {
            monthly_equivalents: {
              all_sources: 1322.6,
              cash_transactions: 0.0,
              bank_transactions: [
                {
                  name: 'Universal Credit',
                  monthly_value: 979.33,
                  excluded_from_income_assessment: false
                },
                {
                  name: 'Child Benefit',
                  monthly_value: 343.27,
                  excluded_from_income_assessment: false
                }
              ]
            }
          },
          other_income: {
            monthly_equivalents: {
              all_sources: {
                friends_or_family: 50.0,
                maintenance_in: 350.0,
                property_or_lodger: 250.0,
                pension: 0.0
              },
              bank_transactions: {
                friends_or_family: 0.0,
                maintenance_in: 200.0,
                property_or_lodger: 250.0,
                pension: 0.0
              },
              cash_transactions: {
                friends_or_family: 50.0,
                maintenance_in: 150.0,
                property_or_lodger: 0.0,
                pension: 0.0
              }
            }
          }
        }
      end

      describe '#as_json' do
        before do
          create :state_benefit, state_benefit_type: universal_credit, gross_income_summary: summary, monthly_value: 979.33
          create :state_benefit, state_benefit_type: child_benefit, gross_income_summary: summary, monthly_value: 343.27
        end

        subject { described_class.new(assessment).as_json }

        it 'returns the expected structure' do
          employment1
          employment2
          expect(subject).to eq expected_results
        end
      end
    end
  end
end
