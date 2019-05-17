require 'rails_helper'

describe 'JSON Assessment response' do
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
