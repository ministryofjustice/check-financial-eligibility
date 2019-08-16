require 'rails_helper'

module WorkflowService
  RSpec.describe SelfEmployed do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment) }

    it 'returns true' do
      # always returns true for now
      expect(service.call).to be true
    end
  end
end
