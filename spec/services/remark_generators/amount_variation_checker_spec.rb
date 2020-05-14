require 'rails_helper'

module RemarkGenerators
  RSpec.describe AmountVariationChecker do
    context 'state benefit payments' do
      let(:amount) { 123.45 }
      let(:dates) { [Date.today, 1.month.ago, 2.month.ago] }
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:collection) { [payment_1, payment_2, payment_3] }

      context 'no variation in amount' do
        let(:payment_1) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[0] }
        let(:payment_2) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[1] }
        let(:payment_3) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[2] }

        it 'does not update the remarks class' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end

      context 'variation in amount' do
        let(:payment_1) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[0] }
        let(:payment_2) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount + 0.01, payment_date: dates[1] }
        let(:payment_3) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount - 0.02, payment_date: dates[2] }

        it 'adds the remark' do
          expect_any_instance_of(Remarks).to receive(:add).with(:state_benefit_payment, :amount_variation, collection.map(&:client_id))
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
      let(:dates) { [Date.today, 1.month.ago, 2.months.ago] }
      let(:amount) { 277.67 }

      context 'no variation in amount' do
        let(:collection) do
          [
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[0], amount: amount),
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[1], amount: amount),
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[2], amount: amount)
          ]
        end

        it 'does not update the remarks class' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end

      context 'varying amounts' do
        let(:collection) do
          [
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[0], amount: amount),
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[1], amount: amount + 0.01),
            create(:housing_cost_outgoing, disposable_income_summary: disposable_income_summary, payment_date: dates[2], amount: amount)
          ]
        end

        it 'adds the remark' do
          expect_any_instance_of(Remarks).to receive(:add).with(:outgoings_housing_cost, :amount_variation, collection.map(&:client_id))
          described_class.call(assessment, collection)
        end

        it 'stores the changed the remarks class on the assessment' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment, collection)
          expect(assessment.reload.remarks.as_json).not_to eq original_remarks
        end
      end
    end
  end
end
