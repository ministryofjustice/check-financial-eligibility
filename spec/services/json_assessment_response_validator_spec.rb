require 'rails_helper'

describe 'JSON Assessment response' do
  before do
    # The response schema references the request schema definitions through an HTTP request, so
    # stub it out here.
    assessment_request_schema = File.read(Rails.root.join('public/schemas/assessment_request.json'))
    stub_request(:get, "http://localhost:3000/schemas/assessment_request.json").
      to_return(:body => assessment_request_schema)
  end

  context 'A valid response' do
    it 'does not create any errors' do
      schema_path = Rails.root.join('public/schemas/assessment_response.json').to_s
      response_hash = AssessmentResponseFixture.ruby_hash
      payload = JSON.pretty_generate(response_hash)
      errors = JSON::Validator.fully_validate(schema_path, payload)
      expect(errors).to be_empty
    end
  end
end
