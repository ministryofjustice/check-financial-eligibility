require 'rspec'

describe 'JsonValidator' do
  let(:payload) do
    {
      "bank_accounts": [
        {
          "description": bank1,
          "value": bank_val1
        },
        {
          "description": bank2,
          "value": bank_val2
        }
      ],
      "non_liquid_capital": [
        {
          "description": nlc1,
          "value": nlc_val1
        },
        {
          "description": nlc2,
          "value": nlc_val2
        }
      ]
    }.to_json
  end

  let(:bank1) { 'ALKEN ASSET MANAGEMENT 10606062' }
  let(:bank2) { 'SANTANDER UK PLC 68346475' }
  let(:bank_val1)  { 85847.05 }
  let(:bank_val2)  { 59389.67 }
  let(:nlc1) { "FTSE tracker unit trust" }
  let(:nlc2) { "Aramco shares"}
  let(:nlc_val1) { 61192.33 }
  let(:nlc_val2) { 100000.0 }

  let(:schema) { JSON.load_file(Rails.root.join("app/json_spike/capitals.json")) }

  let(:validator) { JsonValidator.new(schema, payload) }

  context 'when valid payload with data' do
    it 'returns true' do
      expect(validator).to be_valid
    end
  end

  context 'when valid data with only bank data' do
    let(:payload) do
      {
        "bank_accounts": [
          {
            "description": bank1,
            "value": bank_val1
          },
          {
            "description": bank2,
            "value": bank_val2
          }
        ],
        "non_liquid_capital": []
      }.to_json
    end

    it 'returns true' do
      expect(validator).to be_valid
    end
  end

  context 'when missing descripiton in one item' do
    let(:payload) do
      {
        "bank_accounts": [
          {
            "description": bank1,
            "value": bank_val1
          },
          {
            "value": bank_val2
          }
        ],
        "non_liquid_capital": []
      }.to_json
    end

    it 'is not valid' do
      expect(validator).not_to be_valid
      pp validator.errors
    end
  end
end
