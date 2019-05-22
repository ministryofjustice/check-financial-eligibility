require 'rails_helper'

RSpec.describe CcmsThreshold do
  let(:data) { YAML.load_file Rails.root.join('config/thresholds.yml') }

  describe '.threshold' do
    it 'returns data from yaml file' do
      expect(described_class.value(:capital_upper)).to eq(data['ccms']['capital_upper'])
    end
  end
end
