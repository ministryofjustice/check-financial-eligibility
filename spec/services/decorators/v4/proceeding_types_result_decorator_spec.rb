require "rails_helper"

module Decorators
  module V4
    RSpec.describe ProceedingTypesResultDecorator do
      let(:ptcs) { %w[DA003 DA005 SE013] }
      let(:assessment) { create :assessment, proceeding_type_codes: ptcs }

      before do
        create :assessment_eligibility, assessment: assessment, proceeding_type_code: "DA003", assessment_result: "eligible"
        create :assessment_eligibility, assessment: assessment, proceeding_type_code: "DA005", assessment_result: "eligible"
        create :assessment_eligibility, assessment: assessment, proceeding_type_code: "SE013", assessment_result: "eligible"
      end

      subject(:decorator) { described_class.new(assessment).as_json }

      describe "#as_json" do
        it "returns an array with three elements" do
          expect(decorator).to eq [
            { ccms_code: "DA003", result: "eligible" },
            { ccms_code: "DA005", result: "eligible" },
            { ccms_code: "SE013", result: "eligible" },
          ]
        end
      end
    end
  end
end
