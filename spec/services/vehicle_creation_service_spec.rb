require 'rails_helper'

RSpec.describe VehicleCreationService do
  let(:assessment) { create :assessment }

  before { stub_call_to_json_schema }

  shared_examples 'it does not create any vehicle records' do
    it 'does not create any vehicle records' do
      expect {
        described_class.call(payload)
      }.not_to change { Vehicle.count }
    end
  end

  context 'valid payload' do
    let(:payload) { valid_payload }
    describe '.call' do
      it 'creates vehicle records' do
        expect {
          described_class.call(payload)
        }.to change { assessment.vehicles.count }.by(2)
      end

      it 'returns expected payload' do
        result = described_class.call(payload)
        puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
        ap result
        puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
        ap expected_success_result
        expect(described_class.call(payload)).to eq expected_success_result
      end
    end
  end

  context 'payload does not conform to schema' do
    let(:payload) { invalid_json_payload }
    describe '#call' do
      it_behaves_like 'it does not create any vehicle records'

      it 'returns expected payload with errors' do
        result = described_class.call(payload)
        expect(result).to be_instance_of(OpenStruct)
        expect(result.success).to be false
        expect(result.objects).to be_nil
        expect(result.errors.size).to eq 4
        expect(result.errors[0]).to eq 'Payload did not conform to JSON schema'
        expect(result.errors[1]).to match %r{The property '#/' did not contain a required property of 'assessment_id'}
        expect(result.errors[2]).to match %r{The property '#/' contains additional properties \["unkown_attr"\]}
        expect(result.errors[3]).to match %r{The property '#/vehicles/0' contains additional properties \["extra_vehicle_attr"\]}
      end
    end
  end

  context 'assessment id does not exist' do
    let(:payload) { payload_with_invalid_assessment_id }
    describe '#call' do
      it_behaves_like 'it does not create any vehicle records'

      it 'returns expected payload with errors' do
        result = described_class.call(payload)
        expect(result).to be_instance_of(OpenStruct)
        expect(result.success).to be false
        expect(result.objects).to be_nil
        expect(result.errors.size).to eq 1
        expect(result.errors[0]).to eq 'No such assessment id'
      end
    end
  end

  context 'ActiveRecord validation errors' do
    let(:payload) { payload_with_purchase_date_in_future }
    describe '#call' do
      it_behaves_like 'it does not create any vehicle records'

      it 'returns expected payload with errors' do
        result = described_class.call(payload)
        expect(result).to be_instance_of(OpenStruct)
        expect(result.success).to be false
        expect(result.objects).to be_nil
        expect(result.errors.size).to eq 1
        expect(result.errors[0]).to eq 'Date of purchase cannot be in the future'
      end
    end
  end

  def expected_success_result
    OpenStruct.new(
      success: true,
      objects: assessment.vehicles,
      errors: []
    )
  end

  def valid_payload_hash
    {
      assessment_id: assessment.id,
      vehicles: [
        {
          value: 12_100.0,
          loan_amount_outstanding: 8_250.0,
          date_of_purchase: 3.years.ago.to_date,
          in_regular_use: true
        },
        {
          value: 850.0,
          loan_amount_outstanding: 0,
          date_of_purchase: 8.years.ago.to_date,
          in_regular_use: true
        }
      ]
    }
  end

  def valid_payload
    valid_payload_hash.to_json
  end

  def invalid_json_payload
    hash = valid_payload_hash.dup
    hash[:unkown_attr] = 'xx'
    hash.delete(:assessment_id)
    hash[:vehicles].first[:extra_vehicle_attr] = 23
    hash[:vehicles].last.delete(:load_amount_outstanding)
    hash.to_json
  end

  def payload_with_invalid_assessment_id
    valid_payload_hash.merge(assessment_id: SecureRandom.uuid).to_json
  end

  def payload_with_purchase_date_in_future
    hash = valid_payload_hash.dup
    hash[:vehicles].first[:date_of_purchase] = 4.days.from_now.to_date
    hash.to_json
  end
end
