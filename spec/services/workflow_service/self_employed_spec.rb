require 'rails_helper'

module WorkflowService
  RSpec.describe SelfEmployed do
    let(:particulars) { double AssessmentParticulars }
    let(:service) { described_class.new(particulars) }

    it 'returns true' do
      expect(service.result_for).to be true
    end
  end
end
