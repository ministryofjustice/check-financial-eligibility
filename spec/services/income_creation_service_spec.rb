require 'rails_helper'

RSpec.describe IncomeCreationService do
  let(:assessment) { create :assessment }
  let(:benefit_receipts) { attributes_for_list(:benefit_receipt, 2) }
  let(:wage_slips) { attributes_for_list(:wage_slip, 2) }

  describe '.call' do
    subject do
      described_class.call(
        assessment_id: assessment.id,
        benefits_attributes: benefit_receipts,
        wage_slips_attributes: wage_slips
      )
    end

    it 'generates two wage_slips' do
      expect { subject }.to change { assessment.wage_slips.count }.by(2)
    end

    it 'generates two benefit_receipts' do
      expect { subject }.to change { assessment.benefit_receipts.count }.by(2)
    end

    it 'is successful' do
      expect(subject).to be_success
    end

    it 'has empty errors' do
      expect(subject.errors).to be_empty
    end

    context 'with error' do
      let(:error) { 'An error' }
      let(:wage_slip_with_error) do
        wage_slip = build :wage_slip
        wage_slip.errors.add :base, error
        wage_slip
      end
      before do
        allow(subject).to receive(:wage_slips).and_return([wage_slip_with_error])
      end

      it 'does not generates two wage_slips' do
        expect { subject }.not_to change { assessment.wage_slips.count }
      end

      it 'does not generates two benefit_receipts' do
        expect { subject }.not_to change { assessment.benefit_receipts.count }
      end

      it 'is unsuccessful' do
        expect(subject).not_to be_success
      end

      it 'adds an error' do
        expect(subject.errors).to eq([error])
      end
    end
  end
end
