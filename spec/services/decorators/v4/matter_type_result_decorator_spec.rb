require "rails_helper"

module Decorators
  module V4
    RSpec.describe MatterTypeResultDecorator do
      before(:each) { mock_lfa_responses }

      subject { described_class.new(assessment).as_json }

      let(:assessment) { create :assessment, proceeding_type_codes: ptcs }
      let(:ptcs) { results.keys }

      describe "#as_json" do
        before do
          results.each do |ptc, result|
            create :assessment_eligibility, assessment: assessment, proceeding_type_code: ptc, assessment_result: result
          end
        end

        context "all proceeding types for matter type have same results" do
          let(:results) do
            {
              DA003: "eligible",
              SE013: "ineligible",
              DA005: "eligible",
              SE003: "ineligible"
            }
          end

          it "returns an array of matter type results" do
            expect(subject).to eq [
              { matter_type: "domestic_abuse", result: "eligible" },
              { matter_type: "section8", result: "ineligible" }
            ]
          end
        end

        context "proceeding types in same matter types have different results" do
          let(:results) do
            {
              DA003: "contribution_required",
              SE013: "ineligible",
              DA005: "eligible"
            }
          end

          it "raises an error" do
            expect { subject }.to raise_error RuntimeError, "Different results for matter type domestic_abuse"
          end
        end
      end
    end
  end
end
