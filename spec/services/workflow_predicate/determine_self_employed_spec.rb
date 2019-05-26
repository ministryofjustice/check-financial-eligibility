require 'rails_helper'

module WorkflowPredicate
  RSpec.describe DetermineSelfEmployed do
    let(:particulars) { double AssessmentParticulars }
    let(:service) { described_class.new(particulars) }

    it 'returns false' do
      expect(service.result_for).to be false
    end
  end
end
