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

  context "when dob is invalid and involvement type not applicant" do
    let(:dob) { "3002-12-23" }
    let(:involvement_type) { "defendant" }

    it { expect(validator).not_to be_valid }

    it "displays errors" do
      expect(validator.errors)
        .to include(match(/The property '#\/applicant\/date_of_birth' value "3002-12-23" did not match the rege/))
    end
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
