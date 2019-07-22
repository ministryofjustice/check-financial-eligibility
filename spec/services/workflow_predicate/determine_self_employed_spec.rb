require 'rails_helper'

module WorkflowPredicate
  RSpec.describe DetermineSelfEmployed do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(particulars) }

    it 'returns false' do
      service = described_class.new(assessment)
      expect(service.call).to be false
    end
  end
end
