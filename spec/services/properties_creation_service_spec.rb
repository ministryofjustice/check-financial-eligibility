require 'rails_helper'

RSpec.describe PropertiesCreationService do
  let(:assessment) { create :assessment }
  let(:payload) { valid_payload }

  subject { described_class.call(payload) }

  shared_examples 'error response' do
  end

  describe '.call' do
    context 'valid payload' do
      describe '#success?' do
        it 'returns true' do
          expect(subject.success?).to be true
        end
      end

      describe '#properties' do
        it 'returns array of properties' do
          expect(subject.properties.size).to eq 3
          expect(subject.properties.map(&:class).uniq).to eq [Property]
        end
        it 'returns the ids of the new property records in the response' do
          expect(subject.properties[0].id).to eq assessment.properties[0].id
          expect(subject.properties[1].id).to eq assessment.properties[1].id
          expect(subject.properties[2].id).to eq assessment.properties[2].id
        end
      end

      describe '#errors' do
        it 'returns an empty array' do
          expect(subject.errors).to be_empty
        end
      end

      it 'creates 3 property records for this assessment' do
        expect {
          subject
        }.to change { assessment.properties.count }.by(3)
      end
    end

    context 'invalid assessment id' do
      let(:payload) { invalid_assessment_payload }

      describe '#success?' do
        it 'returns false' do
          expect(subject.success?).to be false
        end
      end

      it 'returns errors' do
        expect(subject.errors.size).to eq 1
        expect(subject.errors.first).to eq 'No such assessment id'
      end

      it 'does not create any property records' do
        expect {
          described_class.call(payload)
        }.not_to change { Property.count }
      end
    end
  end

  def invalid_assessment_payload
    payload = valid_payload_hash.dup
    payload[:assessment_id] = SecureRandom.uuid
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
