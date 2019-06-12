require 'rails_helper'

RSpec.describe AssessmentCreationService do
  let(:remote_ip) { '127.0.0.1' }

  let(:service) { described_class.new(remote_ip, raw_post) }

  before do
    # stub requests to get schemas
    stub_request(:get, 'http://localhost:3000/schemas/assessment_request.json')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: full_schema, headers: {})
  end

  context 'invalid json' do
    let(:raw_post) do
      {
        client_reference_id: 'psr-123',
        submission_date: Date.today,
        matter_proceeding_type: 'xxxx'
      }.to_json
    end
    it 'returns https status 422' do
      service.response_payload
      expect(service.http_status).to eq 422
    end

    it 'has json schema error messages in the response' do
      response_hash = JSON.parse(service.response_payload)
      expect(response_hash['status']).to eq 'error'
      expect(response_hash['errors'][0]).to match %r{The property '#/matter_proceeding_type' value "xxxx" did not match one of the following values}
    end
  end

  context 'ActiveRecord validation error' do
    let(:raw_post) do
      {
        client_reference_id: '',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end

    it 'returns https status 422' do
      service.response_payload
      expect(service.http_status).to eq 422
    end

    it 'has ActiveRecord error messages in the response' do
      response_hash = JSON.parse(service.response_payload)
      expect(response_hash['status']).to eq 'error'
      expect(response_hash['errors'][0]).to eq "Client reference can't be blank"
    end
  end

  context 'valid request' do
    let(:raw_post) do
      {
        client_reference_id: 'psr-123',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }.to_json
    end

    it 'has a http response code of 200' do
      service.response_payload
      expect(service.http_status).to eq 200
    end

    it 'creates an Assessment record' do
      expect {
        service.response_payload
      }.to change { Assessment.count }.by(1)
    end

    it 'contains the expected response' do
      response_hash = JSON.parse(service.response_payload)
      expect(response_hash['status']).to eq 'ok'
      expect(response_hash['assessment_id']).to eq Assessment.last.id
    end

    xit 'contains a link to the next call' do
      expect(response_hash['links'].first['href']).to eq assessments_applicant_path(Assessment.last)
    end
  end

  def full_schema
    File.read(Rails.root.join('public/schemas/assessment_request.json'))
  end
end
