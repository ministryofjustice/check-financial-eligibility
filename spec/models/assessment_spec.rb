require 'rails_helper'
require Rails.root.join('spec/fixtures/assessment_fixture.rb')

RSpec.describe Assessment, type: :model do
  context 'saving request before result is known' do
    let(:payload) { AssessmentFixture.json }

    context 'all fields supplied' do
      it 'saves ok' do
        assessment = Assessment.create!(client_reference_id: 'client-ref-1',
                                        remote_ip: '192.168.9.8',
                                        request_payload: payload)
        expect(assessment.request_payload).to eq payload
      end
    end

    context 'missing ip address' do
      it 'raises' do
        expect {
          Assessment.create!(client_reference_id: 'client-ref-1',
                             request_payload: payload)
        }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Remote ip can't be blank"
      end
    end

    context 'missing request payload' do
      it 'raises' do
        expect {
          Assessment.create!(client_reference_id: 'client-ref-1',
                             remote_ip: '192.168.9.8')
        }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Request payload can't be blank"
      end
    end
  end
end
