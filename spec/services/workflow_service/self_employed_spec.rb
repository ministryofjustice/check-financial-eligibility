require 'rails_helper'

module WorkflowService
  RSpec.describe SelfEmployed do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment) }

    it 'raises not implemented error' do
      expect{
        service.call
      }.to raise_error 'Not Implemented: Check Financial Eligibility has not yet been implemented for self-employed applicants'
    end
  end
end
