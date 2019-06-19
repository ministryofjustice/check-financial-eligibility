require 'rails_helper'

RSpec.describe PropertiesCreationService do
  let(:assessment) { create :assessment }
  describe '.call' do
    it 'returns a valid result structure' do
      result = described_class.call(valid_payload)
      expect(result.success).to be true
      expect(result.objects.size).to eq 3
      expect(result.objects.map(&:class).uniq).to eq [Property]
      expect(result.errors).to be_empty      
    end
  end

  def valid_payload
    {
      assessment_id: assessment.id,
      main_home: {
        value: 500_000,
        outstanding_mortgage: 200,
        percentage_owned: 15,
        shared_with_housing_assoc: true
      },
      additional_properties: [
        {
          value: 1_000,
          outstanding_mortgage: 0,
          percentage_owned: 99,
          shared_with_housing_assoc: false
        },
        {
          value: 10_000,
          outstanding_mortgage: 40,
          percentage_owned: 80,
          shared_with_housing_assoc: true
        }
      ]
    }.to_json
  end
end
