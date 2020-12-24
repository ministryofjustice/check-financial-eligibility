require 'rails_helper'

module RemarkGenerators
  RSpec.describe FrequencyChecker do
    before { create :bank_holiday }

    context 'state benefit payments' do
      let(:amount) { 123.45 }
<<<<<<< HEAD
      let(:dates) { [Date.current, 1.month.ago, 2.month.ago] }
=======
      let(:dates) { [Time.zone.today, 1.month.ago, 2.months.ago] }
>>>>>>> Implement rubocop-rails and necessary fixes
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:payment1) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[0] }
      let(:payment2) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[1] }
      let(:payment3) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[2] }
      let(:collection) { [payment1, payment2, payment3] }

      context 'regular payments' do
<<<<<<< HEAD
        let(:dates) { [Date.current, 1.month.ago, 2.month.ago] }
=======
        let(:dates) { [Time.zone.today, 1.month.ago, 2.months.ago] }
>>>>>>> Implement rubocop-rails and necessary fixes

        it 'does not update the remarks class' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end

      context 'variation in dates' do
        let(:dates) { [2.days.ago, 10.days.ago, 55.days.ago] }

        it 'adds the remark' do
          expect_any_instance_of(Remarks).to receive(:add).with(:state_benefit_payment, :unknown_frequency, collection.map(&:client_id))
          described_class.call(assessment, collection)
        end

        it 'stores the changed the remarks class on the assessment' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).not_to eq original_remarks
        end
      end
    end

    context 'outgoings' do
      let(:disposable_income_summary) { create :disposable_income_summary }
      let(:assessment) { disposable_income_summary.assessment }
      let(:amount) { 277.67 }
      let(:collection) do
        [
          create(:legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[0], amount: amount),
          create(:legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[1], amount: amount),
          create(:legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[2], amount: amount)
        ]
      end

      context 'regular payments' do
        let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

        it 'does not update the remarks class' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end

      context 'irregular dates' do
        let(:dates) { [Date.current, 1.week.ago, 9.weeks.ago] }

        it 'adds the remark' do
          expect_any_instance_of(Remarks).to receive(:add).with(:outgoings_legal_aid, :unknown_frequency, collection.map(&:client_id))
          described_class.call(assessment, collection)
        end

        it 'stores the changed the remarks class on the assessment' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).not_to eq original_remarks
        end

        context 'when childcare costs with an amount variation are declared' do
          let(:collection) do
            [
              create(:childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[0], amount: amount),
              create(:childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[1], amount: amount + 0.01),
              create(:childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[2], amount: amount)
            ]
          end
          context 'if the childcare costs are allowed as an outgoing' do
            before { disposable_income_summary.childcare = 1 }

            it 'adds the remark' do
              expect_any_instance_of(Remarks).to receive(:add).with(:outgoings_childcare, :unknown_frequency, collection.map(&:client_id))
              described_class.call(assessment, collection)
            end

            it 'stores the changed the remarks class on the assessment' do
              original_remarks = assessment.remarks.as_json
              described_class.call(assessment, collection)
              expect(assessment.reload.remarks.as_json).not_to eq original_remarks
            end
          end

          context 'if the childcare costs are not allowed as an outgoing' do
            it 'does not update the remarks class' do
              original_remarks = assessment.remarks.as_json
              described_class.call(assessment, collection)
              expect(assessment.reload.remarks.as_json).to eq original_remarks
            end
          end
        end
      end
    end
  end
end
