require 'rails_helper'

module WorkflowPredicate
  RSpec.describe DeterminePassported do
    let(:assessment) { create :assessment, applicant: applicant }
    let(:service) { described_class.new(assessment) }

    context 'does not receive qualifying benefit' do
      let(:applicant) { create :applicant }
      it 'returns false' do
        expect(service.call).to be false
      end
    end

    context 'receives qualifying benefit' do
      let(:applicant) { create :applicant, :with_qualifying_benfits }
      it 'returns true' do
        expect(service.call).to be true
      end
    end
  end
end
