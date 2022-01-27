require 'rails_helper'

RSpec.describe ApiResponse do
  let(:response) { described_class.new }

  describe '.success' do
    let(:dummy_records) { %w[record_1 record_2] }

    subject { described_class.success(dummy_records) }

    it 'sets success to true' do
      expect(subject.success?).to be true
    end

    it 'populates the objects array' do
      expect(subject.objects).to eq dummy_records
    end

    it 'sets errors to nil' do
      expect(subject.errors).to be_empty
    end
  end

  describe '#as_json' do
    it 'returns a hash' do
      assessment = create :assessment, :with_capital_summary
      assessment.capital_summary.liquid_capital_items << LiquidCapitalItem.new(description: 'sfdfdfd', value: 656.22)
      assessment.capital_summary.liquid_capital_items << LiquidCapitalItem.new(description: 'sfdfdfd', value: 656.22)
      response = described_class.success assessment.capital_summary
      serializable_response = response.as_json
      expect(serializable_response).to be_instance_of(Hash)
      expect(serializable_response.keys).to match_array %w[success objects errors]
    end
  end

  describe '.error' do
    let(:messages) { ['error 1', 'error 2'] }

    subject { described_class.error(messages) }

    it 'sets success to true' do
      expect(subject.success?).to be false
    end

    it 'populates the objects array' do
      expect(subject.objects).to be_nil
    end

    it 'sets errors to nil' do
      expect(subject.errors).to eq messages
    end
  end
end
