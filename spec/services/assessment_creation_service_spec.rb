require 'rails_helper'

RSpec.describe AssessmentCreationService do
  let(:remote_ip) { '127.0.0.1' }

  subject { described_class.new(remote_ip, raw_post) }

  before { stub_call_to_json_schema }

  context 'invalid json' do
    let(:raw_post) do
      {
        client_reference_id: 'psr-123',
        submission_date: Date.today,
        matter_proceeding_type: 'xxxx'
      }.to_json
    end

    it 'is not successful' do
      expect(subject.success?).to eq false
    end

    it 'does not create an assessment ' do
      expect { subject.success? }.not_to change { Assessment.count }
    end

    it 'returns error messages' do
      subject
      expect(subject.errors.first).to match %r{The property '#/matter_proceeding_type' value "xxxx" did not match one of the following values}
    end
  end

  context 'ActiveRecord validation error' do
    let(:raw_post) do
      {
        client_reference_id: '',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end

    it 'is not successful' do
      expect(subject.success?).to eq false
    end

    it 'does not create an assessment ' do
      expect { subject.success? }.not_to change { Assessment.count }
    end

    it 'returns error messages' do
      subject
      expect(subject.errors.first).to eq("Client reference can't be blank")
    end
  end

  context 'valid request' do
    let(:raw_post) do
      {
        client_reference_id: 'psr-123',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end

    it 'is successful' do
      expect(subject.success?).to eq true
    end

    it 'creates an Assessment record' do
      expect { subject.success? }.to change { Assessment.count }.by(1)
    end

    it 'has no errors' do
      expect(subject.errors).to be_empty
    end

    it 'returns the created assessment' do
      expect(subject.assessment.id).to eq Assessment.last.id
    end
  end
end
