require 'rails_helper'

RSpec.describe AssessmentCreationService do
  let(:remote_ip) { '127.0.0.1' }
  let(:raw_post) do
    {
      client_reference_id: 'psr-123',
      submission_date: '2019-06-06',
      matter_proceeding_type: 'domestic_abuse'
    }.to_json
  end

  subject { described_class.call(remote_ip, raw_post) }

  before { stub_call_to_json_schema }

  context 'valid request' do
    it 'is successful' do
      expect(subject.success?).to eq true
    end

    it 'creates an Assessment record' do
      expect { subject.success? }.to change { Assessment.count }.by(1)
    end

    it 'has no errors' do
      expect(subject.errors).to be_empty
    end

    describe '#as_json' do
      it 'returns a successful json struct including the assessment it has created' do
        subject.success?
        expected_response = {
          success: true,
          objects: [Assessment.last],
          errors: []
        }
        expect(subject.as_json).to eq expected_response
      end
    end
  end

  context 'invalid request' do
    let(:remote_ip) { nil }

    it 'is successful' do
      expect(subject.success?).to eq false
    end

    it 'does notcreates an Assessment record' do
      expect { subject.success? }.not_to change { Assessment.count }
    end

    it 'has  errors' do
      expect(subject.errors).to eq ["Remote ip can't be blank"]
    end
  end
end
