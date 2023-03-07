require "rails_helper"

RSpec.describe "JsonValidator" do
  let(:payload) do
    {
      applicant: {
        date_of_birth: dob,
        has_partner_opponent: opponent,
        receives_qualifying_benefit: benefit,
      },
    }.to_json
  end

  let(:dob) { "2002-12-22" }
  let(:involvement_type) { "applicant" }
  let(:opponent) { false }
  let(:benefit) { true }

  let(:schema_name) { "applicant_v5" }

  let(:validator) { JsonValidator.new(schema_name, payload) }

  context "when valid payload" do
    it { expect(validator).to be_valid }
  end

  context "when not all required elements are present" do
    let(:payload) do
      {
        applicant: {
          date_of_birth: dob,
          has_partner_opponent: opponent,
        },
      }.to_json
    end

    it { expect(validator).not_to be_valid }

    it "has the expected errors" do
      expect(validator.errors)
        .to include(match(/The property '#\/applicant' did not contain a required property of 'receives_qualifying_benefit' in schema/))
    end
  end
end
