require 'rails_helper'

RSpec.describe AssessmentsController, type: :request do
  describe 'POST assessments' do
    let(:params) do
      {
        client_reference_id: 'psr-123',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }
    end

    subject { post assessments_path, params: params.to_json }

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

    before { subject }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has a valid payload' do
      expect(json['status']).to eq('ok')
      expect(json['assessment_id']).to eq(Assessment.last.id)
    end

    context 'invalid payload' do
      let(:params) { { matter_proceeding_type: 'xxx' } }

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the errors' do
        expect(json['errors']).not_to be_empty
      end
    end
  end

  def full_schema
    File.read(Rails.root.join('public/schemas/assessment_request.json'))
  end
end
