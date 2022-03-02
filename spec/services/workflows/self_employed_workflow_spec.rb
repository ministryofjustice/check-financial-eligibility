require "rails_helper"

module Workflows
  RSpec.describe SelfEmployedWorkflow do
    describe "# call" do
      let(:assessment) { instance_double Assessment }

      it "raises" do
        expect {
          described_class.call(assessment)
        }.to raise_error RuntimeError, "Not yet implemented: Check Financial ELigibility service currently does not handle self-employed applicants"
      end
    end
  end
end
