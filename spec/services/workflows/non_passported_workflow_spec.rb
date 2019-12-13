require 'rails_helper'

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) { create :assessment }
    describe '.call' do
      it 'raises' do
        expect {
          described_class.call(assessment)
        }.to raise_error RuntimeError, 'Not yet implemented: Check Fincancial Eligibility service currently does not handle non-passported applicant'
      end
    end
  end
end
