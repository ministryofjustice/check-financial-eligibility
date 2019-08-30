require 'rails_helper'

module WorkflowService
  RSpec.describe Passported do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment) }

    context 'applicant is passported' do
      let!(:applicant) { create :applicant, :with_qualifying_benfits, assessment: assessment }
      it 'returns true' do
        expect(service.call).to be true
      end
    end

    context 'applicant is not passported' do
      let!(:applicant) { create :applicant, :without_qualifying_benefits, assessment: assessment }
      it 'raises' do
        expect {
          service.call
        }.to raise_error 'Not yet implemented: Check Financial Eligibility cannot yet handle non-passported applicants'
      end
    end
  end
end
