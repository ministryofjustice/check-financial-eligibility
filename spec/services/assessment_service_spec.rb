require 'rails_helper'

RSpec.describe AssessmentService do
  let(:remote_ip) { '192.168.25.155' }
  let(:request_payload) { double 'request payload' }

  context 'valid payload' do
    it 'calls process payload' do
      service = described_class.new(remote_ip, request_payload)
      validator = double JsonSchemaValidator, valid?: true
      expect(JsonSchemaValidator).to receive(:new).with(request_payload).and_return(validator)
      expect(service).to receive(:process_payload)

      service.call
    end
  end

  context 'invalid payload' do
    it 'calls process errors' do
      service = described_class.new(remote_ip, request_payload)
      validator = double JsonSchemaValidator, valid?: false
      expect(JsonSchemaValidator).to receive(:new).with(request_payload).and_return(validator)
      expect(service).to receive(:parse_errors).with(validator)

      service.call
    end
  end
end
