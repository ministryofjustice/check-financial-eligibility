require 'rails_helper'
require Rails.root.join 'lib/integration_helpers/property_payload_generator.rb'

RSpec.describe PropertyPayloadGenerator do
  describe '#run' do
    let(:generator) { described_class.new(rows) }

    context 'rows in expected order' do
      let(:rows) { rows_in }
      it 'generates the expected payload' do
        expect(generator.run).to eq expected_payload
      end
    end

    context 'first row not main_home or additional_property' do
      let(:rows) { rows_in.slice(1,999) }
      it 'raises if first line not main_home' do
        expect { generator.run }.to raise_error RuntimeError, 'First row of property not main_home or additional_properties'
      end
    end
  end

  def rows_in
    [
      ['properties', 'main_home', 'value', 500_000],
      [nil, nil, 'outstanding_mortgage', 200],
      [nil, nil, 'percentage_owned', 15],
      [nil, nil, 'shared_with_housing_assoc', true],
      [nil, 'additional_properties', 'value', 1000],
      [nil, nil, 'outstanding_mortgage', 0],
      [nil, nil, 'percentage_owned', 99],
      [nil, nil, 'shared_with_housing_assoc', false],
      [nil, nil, 'value', 10_000],
      [nil, nil, 'outstanding_mortgage', 40],
      [nil, nil, 'percentage_owned', 80],
      [nil, nil, 'shared_with_housing_assoc', false]
    ]
  end

  def expected_payload
    {
      properties: {
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
            shared_with_housing_assoc: false
          }
        ]
      }
    }
  end
end
