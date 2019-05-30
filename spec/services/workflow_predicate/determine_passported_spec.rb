require 'rails_helper'

module WorkflowPredicate
  RSpec.describe DeterminePassported do
    let(:assessment) { create :assessment }
    let(:particulars) { AssessmentParticulars.new(assessment) }
    let(:service) { described_class.new(particulars) }

    context 'does not receive qualifying benefit' do
      it 'returns false' do
        expect(service.call).to be false
      end
    end

    context 'receives qualifying benefit' do
      it 'returs true' do
        allow(particulars.request.applicant).to receive(:receives_qualifying_benefit).and_return true
        expect(service.call).to be true
      end
    end
  end
end
