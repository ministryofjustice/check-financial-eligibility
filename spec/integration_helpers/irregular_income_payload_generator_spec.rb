require 'rails_helper'
require Rails.root.join 'lib/integration_helpers/irregular_income_payload_generator.rb'

RSpec.describe IrregularIncomePayloadGenerator do
  describe '#run' do
    let(:rows) { rows_in }
    let(:generator) { described_class.new(rows) }

    it 'generates the expected payload' do
      expect(generator.run).to eq expected_payload
    end
  end

  def rows_in
    [
      ['irregular_income', 'student_loan', 'amount', 12_000.0, nil, nil, nil, nil, nil]
    ]
  end

  def expected_payload
    {
      payments: [
        {
          income_type: 'student_loan',
          frequency: 'annual',
          amount: 12_000.0
        }
      ]
    }
  end
end
