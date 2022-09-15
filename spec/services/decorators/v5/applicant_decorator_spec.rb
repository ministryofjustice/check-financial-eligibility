require "rails_helper"

module Decorators
  module V5
    RSpec.describe ApplicantDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(applicant).as_json }

        context "applicant is nil" do
          let(:applicant) { nil }

          it "returns nil" do
            expect(decorator).to be_nil
          end
        end

        context "applicant exists" do
          let(:applicant) { create :applicant }

          it "has all expected keys present int he returned hash" do
            expected_keys = %i[
              date_of_birth
              involvement_type
              has_partner_opponent
              receives_qualifying_benefit
              self_employed
            ]
            expect(decorator.keys).to eq expected_keys
          end
        end
      end
    end
  end
end
