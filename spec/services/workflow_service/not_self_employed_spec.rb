require 'rails_helper'

module WorkflowService
  RSpec.describe NotSelfEmployed do
    let(:assessment) { create :assessment, :with_applicant }
    let(:service) { described_class.new(assessment) }

    it 'returns true' do
      expect(service.call).to be true
    end
  end
end
