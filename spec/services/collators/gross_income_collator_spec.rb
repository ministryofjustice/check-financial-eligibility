require 'rails_helper'

module Collators
  RSpec.describe GrossIncomeCollator do
    before { create :bank_holiday }

    let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe '.call' do
      subject { described_class.call assessment }

      context 'upper income threshold' do
        before { subject }

        context 'threshold does not apply' do
          it 'calculates the threshold correctly when there are no dependants' do
            expect(gross_income_summary.reload.upper_threshold).to eq 999_999_999_999
          end

          context 'with child dependants' do
            let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant, with_child_dependants: 5 }
            it 'calculates the threshold correctly when there are dependants' do
              expect(gross_income_summary.reload.upper_threshold).to eq 999_999_999_999
            end
          end
        end
      end

      context 'threshold applies' do
        before do
          allow(assessment).to receive(:matter_proceeding_type).and_return 'not_domestic_abuse'
          subject
        end

        context 'threshold applies, no child dependants' do
          it 'calculates the threshold correctly' do
            expect(gross_income_summary.reload.upper_threshold).to eq 2_657
          end
        end

        context 'threshold applies, 2 child dependants' do
          let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant, with_child_dependants: 2 }
          it 'calculates the threshold correctly' do
            expect(gross_income_summary.reload.upper_threshold).to eq 2_657
          end
        end

        context 'threshold applies, 5 child dependants' do
          let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant, with_child_dependants: 5 }
          it 'calculates the threshold correctly' do
            expect(gross_income_summary.reload.upper_threshold).to eq 2_879
          end
        end

        context 'threshold applies, 8 child dependants' do
          let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant, with_child_dependants: 8 }
          it 'calculates the threshold correctly' do
            expect(gross_income_summary.reload.upper_threshold).to eq 3_545
          end
        end

        context 'threshold applies, 10 child dependants' do
          let(:assessment) { create :assessment, :with_gross_income_summary, :with_applicant, with_child_dependants: 10 }
          it 'calculates the threshold correctly' do
            expect(gross_income_summary.reload.upper_threshold).to eq 3_989
          end
        end
      end

      context 'monthly_other_income' do
        context 'there are no other income records' do
          it 'set monthly other income to zero' do
            subject
            expect(gross_income_summary.reload.monthly_other_income).to eq 0.0
          end
        end

        context 'monthly_other_income_sources_exist' do
          before do
            source1 = create :other_income_source, gross_income_summary: gross_income_summary, name: 'friends_or_family'
            source2 = create :other_income_source, gross_income_summary: gross_income_summary, name: 'property_or_lodger'
            create :other_income_payment, other_income_source: source1, payment_date: Date.current, amount: 105.13
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.23
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03

            create :other_income_payment, other_income_source: source2, payment_date: Date.current, amount: 66.45
            create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
            create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
          end

          it 'updates the gross income record with categorised monthly incomes' do
            subject
            gross_income_summary.reload
            expect(gross_income_summary.monthly_state_benefits).to be_zero
            expect(gross_income_summary.maintenance_in).to be_zero
            expect(gross_income_summary.pension).to be_zero
            expect(gross_income_summary.friends_or_family).to eq 105.13
            expect(gross_income_summary.property_or_lodger).to eq 66.45
            expect(gross_income_summary.monthly_other_income).to eq 171.58
            expect(gross_income_summary.total_gross_income).to eq 171.58
          end
        end
      end

      context 'monthly_student_loan' do
        context 'there are no irregular income payments' do
          it 'set monthly student loan to zero' do
            subject
            expect(gross_income_summary.reload.monthly_student_loan).to eq 0.0
          end
        end

        context 'monthly_student_loan exists' do
          let!(:irregular_income_payments) do
            create :irregular_income_payment, gross_income_summary: gross_income_summary, amount: 12_000
          end

          it 'updates the gross income record with categorised monthly incomes' do
            subject
            gross_income_summary.reload
            expect(gross_income_summary.monthly_state_benefits).to be_zero
            expect(gross_income_summary.maintenance_in).to be_zero
            expect(gross_income_summary.pension).to be_zero
            expect(gross_income_summary.monthly_other_income).to eq 0.0
            expect(gross_income_summary.monthly_student_loan).to eq 12_000 / 12
            expect(gross_income_summary.total_gross_income).to eq 12_000 / 12
          end
        end
      end

      context 'version 3' do
        let(:assessment) { create :assessment, :with_gross_income_summary_and_records, :with_applicant, :with_v3 }
        let(:benefits_in_cash) { create :cash_transaction_category, name: 'benefits', operation: 'credit', gross_income_summary: gross_income_summary }
        let(:friends_or_family_in_cash) { create :cash_transaction_category, name: 'friends_or_family', operation: 'credit', gross_income_summary: gross_income_summary }
        let(:maintenance_in_cash) { create :cash_transaction_category, name: 'maintenance_in', operation: 'credit', gross_income_summary: gross_income_summary }
        let(:property_or_lodger_in_cash) { create :cash_transaction_category, name: 'property_or_lodger', operation: 'credit', gross_income_summary: gross_income_summary }
        let(:pension_in_cash) { create :cash_transaction_category, name: 'pension', operation: 'credit', gross_income_summary: gross_income_summary }

        before do
          3.times do
            create :cash_transaction, cash_transaction_category: benefits_in_cash
            create :cash_transaction, cash_transaction_category: friends_or_family_in_cash
            create :cash_transaction, cash_transaction_category: maintenance_in_cash
            create :cash_transaction, cash_transaction_category: property_or_lodger_in_cash
            create :cash_transaction, cash_transaction_category: pension_in_cash
          end
          subject
          gross_income_summary.reload
        end

        it 'updates with totals for all categories based on bank and cash transactions' do
          benefits_total = gross_income_summary.benefits_bank + gross_income_summary.benefits_cash
          friends_or_family_total = gross_income_summary.friends_or_family_bank + gross_income_summary.friends_or_family_cash
          maintenance_in_total = gross_income_summary.maintenance_in_bank + gross_income_summary.maintenance_in_cash
          property_or_lodger_total = gross_income_summary.property_or_lodger_bank + gross_income_summary.property_or_lodger_cash
          pension_total = gross_income_summary.pension_bank + gross_income_summary.pension_cash

          expect(gross_income_summary.benefits_all_sources).to eq benefits_total
          expect(gross_income_summary.friends_or_family_all_sources).to eq friends_or_family_total
          expect(gross_income_summary.maintenance_in_all_sources).to eq maintenance_in_total
          expect(gross_income_summary.property_or_lodger_all_sources).to eq property_or_lodger_total
          expect(gross_income_summary.pension_all_sources).to eq pension_total
        end

        it 'has a total gross income based on all sources and monthly student loan' do
          all_sources_total = gross_income_summary.benefits_all_sources +
                              gross_income_summary.friends_or_family_all_sources +
                              gross_income_summary.maintenance_in_all_sources +
                              gross_income_summary.property_or_lodger_all_sources +
                              gross_income_summary.pension_all_sources +
                              gross_income_summary.monthly_student_loan

          expect(gross_income_summary.total_gross_income).to eq all_sources_total
        end
      end
    end
  end
end
