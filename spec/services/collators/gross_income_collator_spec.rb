require 'rails_helper'

module Collators
  RSpec.describe GrossIncomeCollator do
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
            create :other_income_payment, other_income_source: source1, payment_date: Date.today, amount: 105.13
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.23
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03

            create :other_income_payment, other_income_source: source2, payment_date: Date.today, amount: 66.45
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
    end
  end
end
