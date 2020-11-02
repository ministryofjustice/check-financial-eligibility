require 'rails_helper'

module RemarkGenerators
  RSpec.describe MultiBenefitChecker do
    context 'state benefit payments' do
      let(:amount) { 123.45 }
      let(:dates) { [Date.today, 1.month.ago, 2.month.ago] }
      let(:state_benefit) { create :state_benefit }
      let(:assessment) { state_benefit.gross_income_summary.assessment }
      let(:collection) { [payment_1, payment_2, payment_3] }
      let!(:original_remarks) { assessment.remarks.as_json }

      subject(:call) { described_class.call(assessment, collection) }

      context 'no flags' do
        let(:payment_1) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[0] }
        let(:payment_2) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[1] }
        let(:payment_3) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[2] }

        it 'does not update the remarks class' do
          subject
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end

      context 'variation in amount' do
        let(:payment_1) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[0] }
        let(:payment_2) { create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: dates[1] }
        let(:payment_3) { create :state_benefit_payment, :with_multi_benefit_flag, state_benefit: state_benefit, amount: amount, payment_date: dates[2] }

        it 'adds the remark' do
          expect_any_instance_of(Remarks).to receive(:add).with(:state_benefit_payment, :multi_benefit, collection.map(&:client_id))
          subject
        end

        it 'stores the changed the remarks class on the assessment' do
          subject
          expect(assessment.reload.remarks.as_json).not_to eq original_remarks
        end
      end
    end
  end
end
