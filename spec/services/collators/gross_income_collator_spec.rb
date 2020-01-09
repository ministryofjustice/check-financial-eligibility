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
            source1 = create :other_income_source, gross_income_summary: gross_income_summary
            source2 = create :other_income_source, gross_income_summary: gross_income_summary
            create :other_income_payment, other_income_source: source1, payment_date: Date.today, amount: 105.03
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03
            create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03

            create :other_income_payment, other_income_source: source2, payment_date: Date.today, amount: 66.45
            create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
            create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
          end

          it 'updates the gross income record with the total monthly income' do
            subject
            expect(gross_income_summary.reload.monthly_other_income).to eq 171.48
          end
        end
      end
    end
  end
end
