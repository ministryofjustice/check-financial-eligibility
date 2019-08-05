require 'rails_helper'

RSpec.describe CapitalsCreationService do
  let(:assessment) { create :assessment }
  let(:assessment_id) { assessment.id }
  let(:bank_accounts) { attributes_for_list :bank_account, 2 }
  let(:non_liquid_assets) { attributes_for_list :non_liquid_asset, 2 }

  subject do
    described_class.call(
      assessment_id: assessment_id,
      bank_accounts_attributes: bank_accounts,
      non_liquid_capitals_attributes: non_liquid_assets
    )
  end

  describe '.call' do
    it 'creates bank accounts for this assessment' do
      expect { subject }.to change { assessment.bank_accounts.count }.by(bank_accounts.count)
      bank_accounts.each do |bank_account|
        expect(assessment.bank_accounts.find_by!(name: bank_account[:name])[:lowest_balance].to_f).to eq(bank_account[:lowest_balance])
      end
    end

    it 'creates non_liquid_assets for this assessment' do
      expect { subject }.to change { assessment.non_liquid_assets.count }.by(non_liquid_assets.count)

      non_liquid_assets.each do |non_liquid_asset|
        expect(assessment.non_liquid_assets.find_by!(description: non_liquid_asset[:description])[:value].to_f).to eq(non_liquid_asset[:value])
      end
    end

    describe '#success?' do
      it 'returns true' do
        expect(subject.success?).to be true
      end
    end

    describe '#capital' do
      it 'returns the created capital' do
        expect(subject.capital[:bank_accounts].count).to eq(bank_accounts.count)
        expect(subject.capital[:non_liquid_assets].count).to eq(non_liquid_assets.count)
        expect(subject.capital[:bank_accounts].first.assessment.id).to eq(assessment.id)
        expect(subject.capital[:non_liquid_assets].first.assessment.id).to eq(assessment.id)
      end
    end

    context 'no such assessment id' do
      let(:assessment_id) { SecureRandom.uuid }

      it 'does not createany bank account' do
        expect { subject }.not_to change { BankAccount.count }
      end

      it 'does not create any non_liquid_asset' do
        expect { subject }.not_to change { NonLiquidAsset.count }
      end

      describe '#success?' do
        it 'returns false' do
          expect(subject.success?).to be false
        end
      end

      describe 'errors' do
        it 'returns an error' do
          expect(subject.errors.size).to eq 1
          expect(subject.errors[0]).to eq 'No such assessment id'
        end
      end
    end
  end
end
