require 'rails_helper'

module WorkflowService
  RSpec.describe NotSelfEmployed do
    let(:assessment) { create :assessment, :with_applicant }
    let(:service) { described_class.new(assessment) }

    it 'raises not implemented error' do
      expect{
        service.call
      }.to raise_error 'Not Implemented: Check Financial Benefit has not yet been implemented for non-passported applicants'
    end
  end
end
