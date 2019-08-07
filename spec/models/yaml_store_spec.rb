require 'rails_helper'

RSpec.describe YamlStore do
  let(:file_path) { data_file_path 'simple_thresholds.yml' }
  let(:data) { YAML.load_file file_path }

  describe '#value' do
    let(:threshold) { Faker::Number.number(digits: 4) }
    let(:data) { { foo: threshold } }
    let(:threshold_store) { described_class.new(data) }

    it 'returns threshold' do
      expect(threshold_store.value(:foo)).to eq(threshold)
    end

    it 'raises error if unknown' do
      expect { threshold_store.value(:unknown) }.to raise_error(described_class::KeyNotRecognisedError)
    end

    context 'with string keyed data' do
      let(:data) { { 'foo' => threshold } }

      it 'returns threshold' do
        expect(threshold_store.value(:foo)).to eq(threshold)
      end
    end
  end

  describe '.from_yaml_file' do
    let(:threshold_store) { described_class.from_yaml_file(file_path) }

    it 'returns data from file' do
      expect(threshold_store.value(:capital_lower)).to eq(data['capital_lower'])
    end
  end
end
