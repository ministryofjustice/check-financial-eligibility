require 'rails_helper'

RSpec.describe CapitalsCreationService do
  let(:assessment) { create :assessment }
  let(:assessment_id) { assessment.id }
  let(:capital_summary) { assessment.capital_summary }
  let(:bank_accounts) { [] }
  let(:non_liquid_assets) { [] }
  let(:bank_name_1)  { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
  let(:bank_name_2)  { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
  let(:item_1) { Faker::Appliance.equipment }
  let(:value_1) { BigDecimal(Faker::Number.decimal(r_digits: 2), 2) }
  let(:value_2) { BigDecimal(Faker::Number.decimal(r_digits: 2), 2) }

  subject do
    described_class.call(
      assessment_id: assessment_id,
      bank_accounts_attributes: bank_accounts,
      non_liquid_capitals_attributes: non_liquid_assets
    )
  end

  describe '.call' do
    context 'with empty bank_accounts and non_liquid_capital' do
      it 'returns an instance of CapitalCreationObject' do
        expect(subject).to be_instance_of(described_class)
      end

      it 'does not create any capital item records' do
        expect(assessment.capital_summary.capital_items).to be_empty
      end
    end

    context 'with liquid assets only' do
      let(:bank_accounts) { liquid_assets_hash }

      before { subject }

      it 'creates liquid capital items' do
        expect(capital_summary.liquid_capital_items.size).to eq 2
        items = capital_summary.liquid_capital_items.order(:created_at)

        expect(items.first.description).to eq bank_name_1
        expect(items.first.value).to eq value_1
        expect(items.last.description).to eq bank_name_2
        expect(items.last.value).to eq value_2
      end

      it 'does not create non-liquid capital items' do
        expect(capital_summary.non_liquid_capital_items).to be_empty
      end
    end

    context 'non_liquid_capital_items_only' do
      let(:non_liquid_assets) { non_liquid_assets_hash }

      before { subject }

      it 'creates non liquid capital items' do
        expect(capital_summary.non_liquid_capital_items.size).to eq 1
        expect(capital_summary.non_liquid_capital_items.first.description).to eq item_1
        expect(capital_summary.non_liquid_capital_items.first.value).to eq value_1
      end
    end
  end

  describe '#success?' do
    it 'returns true' do
      expect(subject.success?).to be true
    end
  end

  describe '#capital_summary' do
    let(:bank_accounts) { liquid_assets_hash }
    let(:non_liquid_assets) { non_liquid_assets_hash }

    it 'returns the created capital summary record' do
      result = subject.capital_summary
      expect(result).to be_instance_of(CapitalSummary)
    end
  end

  def liquid_assets_hash
    [
      {
        description: bank_name_1,
        value: value_1
      },
      {
        description: bank_name_2,
        value: value_2
      }
    ]
  end

  def non_liquid_assets_hash
    [
      {
        description: item_1,
        value: value_1
      }
    ]
  end

  context 'no such assessment id' do
    let(:assessment_id) { SecureRandom.uuid }

    it 'does not create capital_items' do
      expect { subject }.not_to change { CapitalItem.count }
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
