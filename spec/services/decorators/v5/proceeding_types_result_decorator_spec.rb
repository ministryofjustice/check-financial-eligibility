require "rails_helper"

module Decorators
  module V5
    RSpec.describe ProceedingTypesResultDecorator do
      let(:proceeding_types) { [%w[DA003 A], %w[DA005 Z], %w[SE013 W]] }
      let(:assessment) { create :assessment, proceedings: proceeding_types }

      before do
        assessment.proceeding_types.each do |pt|
          create :assessment_eligibility, assessment:, proceeding_type_code: pt.ccms_code, assessment_result: "eligible"
        end
      end

      subject(:decorator) { described_class.new(assessment.eligibilities, assessment.proceeding_types).as_json }

      describe "#as_json" do
        it "returns an array with three elements" do
          expect(decorator).to eq expected_result
        end
      end

      def expected_result
        [
          {
            ccms_code: "DA003",
            client_involvement_type: "A",
            upper_threshold: 0.0,
            lower_threshold: 0.0,
            result: "eligible",
          },
          {
            ccms_code: "DA005",
            client_involvement_type: "Z",
            upper_threshold: 0.0,
            lower_threshold: 0.0,
            result: "eligible",
          },
          {
            ccms_code: "SE013",
            client_involvement_type: "W",
            upper_threshold: 0.0,
            lower_threshold: 0.0,
            result: "eligible",
          },
        ]
      end
    end
  end
end
