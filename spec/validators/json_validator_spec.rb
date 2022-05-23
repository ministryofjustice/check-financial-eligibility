require "rails_helper"

RSpec.describe "JsonValidator" do
  let(:payload) do
    {
      applicant: {
        date_of_birth: dob,
        involvement_type:,
        has_partner_opponent: opponent,
        receives_qualifying_benefit: benefit,
      },
    }.to_json
  end

  let(:dob) { "2002-12-22" }
  let(:involvement_type) { "applicant" }
  let(:opponent) { false }
  let(:benefit) { true }

  let(:schema_name) { "applicant" }

  let(:validator) { JsonValidator.new(schema_name, payload) }

  context "when valid payload" do
    it "returns true" do
      expect(validator).to be_valid
    end
  end

  context "when dob is invalid and involvement type not applicant" do
    let(:dob) { "3002-12-23" }
    let(:involvement_type) { "defendant" }

    it "is not valid" do
      expect(validator).not_to be_valid
    end

    it "displays errors" do
      errors = validator.errors
      expect(errors)
        .to include(match(/The property '#\/applicant\/date_of_birth' value "3002-12-23" did not match the rege/))
        .and include(match(/The property '#\/applicant\/involvement_type' value "defendant" did not match one of the following values: applicant in schema file:/))
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
      errors = validator.errors
      expect(errors)
        .to include(match(/The property '#\/applicant' did not contain a required property of 'involvement_type' in schema/))
        .and include(match(/The property '#\/applicant' did not contain a required property of 'receives_qualifying_benefit' in schema/))
    end
  end
end
