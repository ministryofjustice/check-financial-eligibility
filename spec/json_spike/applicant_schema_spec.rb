require 'rspec'

describe 'JsonValidator' do
  let(:payload) do
    {
      applicant: {
        date_of_birth: dob,
        involvement_type: involvement_type,
        has_partner_opponent: opponent,
        receives_qualifying_benefit: benefit
      }
    }.to_json
  end

  let(:dob) { '2002-12-22' }
  let(:involvement_type) { "applicant" }
  let(:opponent) { false }
  let(:benefit) { 'yes' }

  let(:schema_location) { 'https://check-financial-eligibility.cloud-platform.service.justice.gov.uk/schemas/applicant'}
  let(:schema) { JSON.load_file(Rails.root.join("app/json_spike/applicant.json")) }

  let(:validator) { JsonValidator.new(schema, payload) }

  context 'when valid payload' do
    it 'returns true' do
      expect(validator).to be_valid
    end
  end

  context 'when dob is invalid and involvement type not applicant' do
    let(:dob) { '3002-1223' }
    let(:involvement_type) { 'defendant' }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'displays errors' do
      errors = validator.errors
      expect(errors).to eq(
                          [
                            "The property '#/applicant/date_of_birth' value \"3002-1223\" did not match the regex '^[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]$' in schema #{schema_location}",
                            "The property '#/applicant/involvement_type' value \"defendant\" did not match one of the following values: applicant in schema #{schema_location}"
                          ]
                        )
    end
  end

  context 'when receives_qualifying_benefit is not a valid enum value' do
    let(:benefit) { 'true' }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'returns an error message' do
      expect(validator.errors).to eq ["The property '#/applicant/receives_qualifying_benefit' value \"true\" did not match one of the following values: yes, no in schema #{schema_location}"]
    end
  end

  context 'when not all required elements are present' do
    let(:payload) do
      {
        applicant: {
          date_of_birth: dob,
          has_partner_opponent: opponent,
        }
      }.to_json
    end

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'has the expected errors' do
      errors = validator.errors
      expect(errors.size).to eq 2
      expect(errors.first).to eq "The property '#/applicant' did not contain a required property of 'involvement_type' in schema #{schema_location}"
      expect(errors.last).to eq "The property '#/applicant' did not contain a required property of 'receives_qualifying_benefit' in schema #{schema_location}"
    end
  end

end
