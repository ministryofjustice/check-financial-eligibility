require 'rails_helper'
require Rails.root.join 'lib/integration_helpers/deeply_nested_payload_generator.rb'

RSpec.describe DeeplyNestedPayloadGenerator do
  let(:client_id) { DeeplyNestedPayloadGenerator::FAKE_CLIENT_ID }

  describe '#run' do
    let(:type) { :other_incomes }
    let(:rows) { rows_in }
    let(:generator) { described_class.new(rows, type) }

    it 'generates the expected payload' do
      expect(generator.run).to eq expected_payload
    end
  end

  def rows_in
    [
      %w[other_incomes friends_or_family],
      [nil, nil, 'date', Date.parse('2020-02-07')],
      [nil, nil, 'amount', 250.0],
      [nil, nil, 'date', Date.parse('2020-02-08')],
      [nil, nil, 'client_id', client_id],
      [nil, nil, 'amount', 250.0],
      [nil, nil, 'date', Date.parse('2020-05-26')],
      [nil, nil, 'client_id', client_id],
      [nil, nil, 'amount', 250.0]
    ]
  end

  def expected_payload
    { other_incomes: [
      { source: 'friends_or_family',
        payments: [
          {
            client_id: client_id
          },
          {
            date: Date.parse('2020-02-07'),
            client_id: client_id,
            amount: 250.0
          },
          {
            date: Date.parse('2020-02-08'),
            client_id: client_id,
            amount: 250.0
          },
          {
            date: Date.parse('2020-05-26'),
            client_id: client_id,
            amount: 250.0
          }
        ] }
    ] }
  end
end
