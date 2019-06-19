require 'rails_helper'

RSpec.describe PropertiesCreationService do
  before { stub_call_to_json_schema }

  let(:assessment) { create :assessment }

  shared_examples 'error response' do
    it 'does not create any property records' do
      expect {
        described_class.call(payload)
      }.not_to change { Property.count }
    end
  end

  describe '.call' do
    context 'valid payload' do
      it 'returns a valid success response' do
        result = described_class.call(valid_payload)
        expect(result.success).to be true
        expect(result.objects.size).to eq 3
        expect(result.objects.map(&:class).uniq).to eq [Property]
        expect(result.errors).to be_empty
      end

      it 'creates 3 property records for this assessment' do
        expect {
          described_class.call(valid_payload)
        }.to change { assessment.properties.count }.by(3)
      end

      it 'returns the ids of the new property records in the response' do
        result = described_class.call(valid_payload)
        expect(result.objects[0].id).to eq assessment.properties[0].id
        expect(result.objects[1].id).to eq assessment.properties[1].id
        expect(result.objects[2].id).to eq assessment.properties[2].id
      end
    end

    context 'invalid json' do
      let(:payload)  { invalid_json_payload }
      it 'returns error response' do
        response = described_class.call(payload)
        expect(response.success).to be false
        expect(response.objects).to be_nil
        expect(response.errors[0]).to match %r{The property '#/' did not contain a required property of 'assessment_id'}
        expect(response.errors[1]).to match %r{The property '#/' contains additional properties \["extra_root_attr"\]}
        expect(response.errors[2]).to match %r{The property '#/properties/main_home' did not contain a required property of 'percentage_owned'}
        expect(response.errors[3]).to match %r{The property '#/properties/main_home' contains additional properties \["extra_main_home_attr"\]}
        expect(response.errors[4]).to match %r{The property '#/properties/additional_properties/0' contains additional properties \["extra_main_home_attr"\]}
      end

      it_behaves_like 'error response'
    end

    context 'invalid assessment id' do
      let(:payload) { invalid_assessment_payload }

      it 'returns error response' do
        response = described_class.call(payload)
        expect(response.success).to be false
        expect(response.objects).to be_nil
        expect(response.errors.size).to eq 1
        expect(response.errors.first).to eq 'No such assessment id'
      end

      it_behaves_like 'error response'
    end

    context 'ActiveRecord errors' do
      let(:payload) { active_record_error_payload }

      it 'returns error response' do
        response = described_class.call(payload)
        expect(response.success).to be false
        expect(response.objects).to be_nil
        expect(response.errors.size).to eq 1
        expect(response.errors.first).to eq 'Value must be greater than 0'
      end
    end
  end

  def invalid_json_payload
    payload = valid_payload_hash.dup
    payload[:extra_root_attr] = 1
    payload.delete(:assessment_id)
    payload[:properties][:main_home][:extra_main_home_attr] = 3
    payload[:properties][:additional_properties].first[:extra_main_home_attr] = 3
    payload[:properties][:main_home].delete(:percentage_owned)
    payload.to_json
  end

  def invalid_assessment_payload
    payload = valid_payload_hash.dup
    payload[:assessment_id] = SecureRandom.uuid
    payload.to_json
  end

  def active_record_error_payload
    payload = valid_payload_hash.dup
    payload[:properties][:main_home][:value] = 0
    payload.to_json
  end

  def valid_payload_hash
    {
      assessment_id: assessment.id,
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
            shared_with_housing_assoc: true
          }
        ]
      }
    }
  end

  def valid_payload
    valid_payload_hash.to_json
  end
end
