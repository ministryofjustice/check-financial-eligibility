require 'rails_helper'

describe BaseWorkflowService do
  let(:service) { described_class.new(particulars) }
  let(:request_hash) { AssessmentRequestFixture.ruby_hash }
  let(:assessment) { create :assessment, request_payload: request_hash.to_json }
  let(:particulars) { AssessmentParticulars.new(assessment) }

  xdescribe 'method missing' do
    it 'passes unknown methods to its superclass' do
      expect {
        service.unknown_method
      }.to raise_error NoMethodError, /undefined method `unknown_method'/
    end
  end

  xdescribe '#respond_to_missing?' do
    it 'responds to methods it knows about' do
      expect(service.respond_to?(:applicant)).to be true
    end

    it 'does not respond to unknown methods' do
      expect(service.respond_to?(:unknown_method)).to be false
    end
  end
end
