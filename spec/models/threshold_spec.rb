require 'rails_helper'

RSpec.describe Threshold do
  subject do
    # Cloning the class so data file path can be customized - so not using product data in tests
    klass = Class.new(Threshold)
    klass.data_folder data_file_path('thresholds')
    klass
  end

  let(:path) { data_file_path('thresholds/8-Apr-2019.yml') }
  let(:threshold) { subject.new(path) }
  let(:data) { YAML.load_file(path).deep_symbolize_keys }

  describe '.data' do
    let('file_dates') { %w[8-Apr-2018 8-Apr-2019 8-Apr-2020] }

    it 'has datetime keys based on file name' do
      keys = file_dates.map { |d| Time.parse("#{d} 00:00") }
      expect(subject.data.keys).to contain_exactly(*keys)
    end

    it 'has instances as values' do
      expect(subject.data.values.all? { |v| v.is_a?(described_class) }).to be true
      expect(subject.data.values.map(&:name)).to contain_exactly(*file_dates)
    end
  end

  describe '.value_for' do
    let(:time) { Time.parse('9-June-2019 12:35') }

    it 'returns the expected value' do
      expect(subject.value_for(:capital_lower, at: time)).to eq(data[:capital_lower])
    end

    context 'for dates before oldest' do
      let(:time) { Time.parse('9-June-2001 12:35') }
      let(:path) { data_file_path('thresholds/8-Apr-2018.yml') }

      it 'returns the value from oldest file' do
        expect(subject.value_for(:capital_lower, at: time)).to eq(data[:capital_lower])
      end
    end
  end

  describe '#start_at' do
    it 'derived from the file name' do
      expect(threshold.start_at).to eq(Time.parse('8-Apr-2019'))
    end
  end

  describe '#store' do
    it 'data extracted from file' do
      expect(threshold.store.data).to eq(data)
    end
  end
end
