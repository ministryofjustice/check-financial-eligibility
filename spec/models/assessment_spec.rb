require 'rails_helper'
require Rails.root.join('spec/fixtures/assessment_request_fixture.rb')

RSpec.describe Assessment, type: :model do
  context 'saving request before result is known' do
    let(:payload) { AssessmentRequestFixture.json }

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
        }.to raise_error ActiveRecord::NotNullViolation, /null value in column "remote_ip"/
      end
    end

    context 'missing request payload' do
      it 'raises' do
        expect {
          Assessment.create!(client_reference_id: 'client-ref-1',
                             remote_ip: '192.168.9.8')
        }.to raise_error ActiveRecord::NotNullViolation, /null value in column "request_payload"/
      end
    end
  end
end
