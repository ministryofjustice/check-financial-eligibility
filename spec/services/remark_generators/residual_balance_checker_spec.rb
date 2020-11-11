require 'rails_helper'

module RemarkGenerators
  RSpec.describe ResidualBalanceChecker do
    let(:assessment) { create :assessment, capital_summary: capital_summary }
    let(:capital_summary) { create :capital_summary, lower_threshold: 3000, assessed_capital: 4000 }

    context 'when a residual balance exists and assessed capital is above the lower threshold' do
      let!(:current_account) { create :liquid_capital_item, description: 'Current accounts', value: 100, capital_summary: capital_summary }

      it 'adds the remark when a residual balance exists' do
        expect_any_instance_of(Remarks).to receive(:add).with(:current_account_balance, :residual_balance, [])
        described_class.call(assessment)
      end

      it 'stores the changed the remarks class on the assessment' do
        original_remarks = assessment.remarks.as_json
        described_class.call(assessment)
        expect(assessment.reload.remarks.as_json).not_to eq original_remarks
      end
    end

    context 'when there is no residual balance' do
      let!(:current_account) { create :liquid_capital_item, description: 'Current accounts', value: 0, capital_summary: capital_summary }

      it 'does not update the remarks class' do
        original_remarks = assessment.remarks.as_json
        described_class.call(assessment)
        expect(assessment.reload.remarks.as_json).to eq original_remarks
      end
    end

    context 'when capital assessment is below the lower threshold' do
      let(:capital_summary) { create :capital_summary, lower_threshold: 3000, assessed_capital: 1000 }

      it 'does not update the remarks class' do
        original_remarks = assessment.remarks.as_json
        described_class.call(assessment)
        expect(assessment.reload.remarks.as_json).to eq original_remarks
      end
    end

    context 'when there is no residual balance and assessed capital is below the lower threshold' do
      let(:capital_summary) { create :capital_summary, lower_threshold: 3000, assessed_capital: 1000 }
      let!(:current_account) { create :liquid_capital_item, description: 'Current accounts', value: 0, capital_summary: capital_summary }

      it 'does not update the remarks class' do
        original_remarks = assessment.remarks.as_json
        described_class.call(assessment)
        expect(assessment.reload.remarks.as_json).to eq original_remarks
      end
    end

    context 'with multiple current accounts' do
      context 'when there is a residual_balance in any account' do
        let!(:current_account1) { create :liquid_capital_item, description: 'Current accounts', value: 100, capital_summary: capital_summary }
        let!(:current_account2) { create :liquid_capital_item, description: 'Current accounts', value: -200, capital_summary: capital_summary }

        it 'adds the remark when a residual balance exists' do
          expect_any_instance_of(Remarks).to receive(:add).with(:current_account_balance, :residual_balance, [])
          described_class.call(assessment)
        end
      end

      context 'when there is no residual_balance in any account' do
        let!(:current_account1) { create :liquid_capital_item, description: 'Current accounts', value: 0, capital_summary: capital_summary }
        let!(:current_account2) { create :liquid_capital_item, description: 'Current accounts', value: -100, capital_summary: capital_summary }

        it 'does not update the remarks class' do
          original_remarks = assessment.remarks.as_json
          described_class.call(assessment)
          expect(assessment.reload.remarks.as_json).to eq original_remarks
        end
      end
    end
  end
end
