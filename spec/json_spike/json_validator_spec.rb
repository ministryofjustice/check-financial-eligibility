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

  let(:schema) do
    {
      '$id' => "check_financial_eligibility/schemas/applicant",
      type: :object,
      required: [:applicant],
      properties: {
        applicant: {
          type: :object,
          properties: {
            date_of_birth: {
              type: :string,
              pattern: "^[1-2][0-9]{3}-[0-1][0-9]-[0-3][0-9]$"
            },
            involvement_type: {
              type: :string,
              pattern: "^applicant$"
            },
            has_partner_opponent: {type: :boolean },
            receives_qualifying_benefit: {
              type: :string,
              pattern: "(^yes$)|(^no$)"
            }
          },
          required: %w[date_of_birth involvement_type has_partner_opponent receives_qualifying_benefit]
        }
      }
    }.to_json
  end

  let(:validator) { JsonValidator.new(schema, payload) }

  context 'when valid payload' do
    it 'returns true' do
      expect(validator).to be_valid
    end
  end

  context 'when dob is invalid and involvement type not applicant' do
    let(:dob) { '3002-12-23' }
    let(:involvement_type) { 'defendant' }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'displays errors' do
      errors = validator.errors
      expect(errors.first).to match /The property '#\/applicant\/date_of_birth' value \"3002-12-23\" did not match the regex '\^\[1-2\]\[0-9\]\{3\}-\[0-1\]\[0-9\]-\[0-3\]\[0-9\]\$' in schema/
      expect(errors.last).to match /The property '#\/applicant\/involvement_type' value \"defendant\" did not match the regex '\^applicant\$' in schema/
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
      expect(errors.first).to match /The property '#\/applicant' did not contain a required property of 'involvement_type' in schema/
      expect(errors.last).to match /The property '#\/applicant' did not contain a required property of 'receives_qualifying_benefit' in schema/
    end
  end

end
