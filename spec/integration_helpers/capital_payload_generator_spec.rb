require 'rails_helper'
require Rails.root.join 'lib/integration_helpers/capitals_payload_generator.rb'

RSpec.describe CapitalsPayloadGenerator do
  describe '#run' do
    let(:rows) { rows_in }
    let(:generator) { described_class.new(rows) }

    it 'generates the expected payload' do
      expect(generator.run).to eq expected_payload
    end
  end

  def rows_in
    [
      ['capitals', 'bank_accounts', 'description', 'Bank acct 1'],
      [nil, nil, 'value', 35.44],
      [nil, nil, 'description', 'Bank acct 2'],
      [nil, nil, 'value', 7888.42],
      [nil, 'non_liquid_capital', 'description', 'Picture of sunflowers'],
      [nil, nil, 'value', 25_000_000],
      [nil, nil, 'description', 'fake Ming vase'],
      [nil, nil, 'value', 255.00]
    ]
  end

  def expected_payload
    {
      bank_accounts: [
        { description: 'Bank acct 1', value: 35.44 },
        { description: 'Bank acct 2', value: 7888.42 }
      ],
      non_liquid_capital: [
        { description: 'Picture of sunflowers', value: 25_000_000 },
        { description: 'fake Ming vase', value: 255.00 }
      ]
    }
  end
end
