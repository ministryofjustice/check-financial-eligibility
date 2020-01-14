require 'rails_helper'
require Rails.root.join 'lib/integration_helpers/outgoings_payload_generator.rb'

RSpec.describe OutgoingsPayloadGenerator do
  describe '#run' do
    let(:rows) { rows_in }
    let(:generator) { described_class.new(rows) }

    it 'generates the expected payload' do
      expect(generator.run).to eq expected_payload
    end
  end

  def rows_in
    [
      ['outgoings', 'housing_costs', 'payment_date', Date.parse('2019-01-26')],
      [nil, nil, 'type', 'mortgage'],
      [nil, nil, 'amount', 301.11],
      [nil, nil, 'payment_date', Date.parse('2019-02-26')],
      [nil, nil, 'type', 'mortgage'],
      [nil, nil, 'amount', 302.22],
      [nil, nil, 'payment_date', Date.parse('2019-03-26')],
      [nil, nil, 'type', 'mortgage'],
      [nil, nil, 'amount', 303.33],
      [nil, 'childcare', 'payment_date', Date.parse('2019-01-26')],
      [nil, nil, 'amount', 51.10],
      [nil, nil, 'payment_date', Date.parse('2019-02-26')],
      [nil, nil, 'amount', 52.20],
      [nil, nil, 'payment_date', Date.parse('2019-03-26')],
      [nil, nil, 'amount', 53.30]
    ]
  end

  def expected_payload
    {
      outgoings: [
        {
          name: 'housing_costs',
          payments: [
            {
              payment_date: Date.parse('2019-01-26'),
              type: 'mortgage',
              amount: 301.11
            },
            {
              payment_date: Date.parse('2019-02-26'),
              type: 'mortgage',
              amount: 302.22
            },
            {
              payment_date: Date.parse('2019-03-26'),
              type: 'mortgage',
              amount: 303.33
            }
          ]
        },
        {
          name: 'childcare',
          payments: [
            {
              payment_date: Date.parse('2019-01-26'),
              amount: 51.1
            },
            {
              payment_date: Date.parse('2019-02-26'),
              amount: 52.2
            },
            {
              payment_date: Date.parse('2019-03-26'),
              amount: 53.3
            }
          ]
        }
      ]
    }
  end
end
