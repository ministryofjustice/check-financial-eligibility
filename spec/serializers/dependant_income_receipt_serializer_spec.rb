require 'rails_helper'

RSpec.describe DependantIncomeReceiptSerializer do
  let(:dependant) { create :dependant }
  let(:serializer) { DependantSerializer.new(dependant) }

  it 'includes the expected JSON attributes' do
    expect(serializer.to_json).to include('dependant_income_receipts')
    expect(serializer.to_json).to include('amount')
    expect(serializer.to_json).to include('date_of_payment')
  end

  it 'does not contain invalid attributes in the JSON' do
    expect(serializer.to_json).not_to include('dummy')
  end

  it 'should have attributes that match the dependant income receipts' do
    expect(serializer.serializable_hash.dig(:dependant_income_receipts, 0, :amount)).to eq(dependant.dependant_income_receipts[0].amount)
    expect(serializer.serializable_hash.dig(:dependant_income_receipts, 0, :date_of_payment)).to eq(dependant.dependant_income_receipts[0].date_of_payment)
  end
end
