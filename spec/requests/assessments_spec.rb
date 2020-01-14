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
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:before_request) { nil }

    subject { post assessments_path, params: params.to_json, headers: headers }

    before do
      before_request
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has a valid payload', :show_in_doc do
      expected_response = {
        success: true,
        objects: [Assessment.last],
        errors: []
      }.to_json
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end

    context 'Active Record Error in service' do
      let(:before_request) do
        creation_service = double Creators::AssessmentCreator, success?: false, errors: ['error creating record']
        allow(Creators::AssessmentCreator).to receive(:call).and_return(creation_service)
      end

      it 'returns http unprocessable_entity' do
        expect(response).to have_http_status(422)
      end

      it 'returns error json payload', :show_in_doc do
        expected_response = {
          errors: ['error creating record'],
          success: false
        }
        expect(parsed_response).to eq expected_response
      end
    end

    context 'invalid matter proceeding type' do
      let(:params) { { matter_proceeding_type: 'xxx', submission_date: '2019-07-01' } }

      it_behaves_like 'it fails with message', %(Invalid parameter 'matter_proceeding_type' value "xxx": Must be one of: <code>domestic_abuse</code>.)
    end

    context 'missing submission date' do
      let(:params) do
        {
          matter_proceeding_type: 'domestic_abuse',
          client_reference_id: 'psr-123'
        }
      end

      it_behaves_like 'it fails with message', 'Missing parameter submission_date'
    end
  end

  describe 'GET /assessments/:id' do
    let(:option) { :below_lower_threshold }

    subject { get assessment_path(assessment), headers: headers }

    context 'no version specified' do
      let(:headers) { { 'Accept' => 'application/json' } }
      context 'passported' do
        let(:assessment) { create :assessment, :passported }

        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns capital summary data as json' do
          subject
          expect(parsed_response).to eq(JSON.parse(Decorators::ResultDecorator.new(assessment.reload).to_json, symbolize_names: true))
        end

        it 'has called the workflow and assessor' do
          expect(Workflows::MainWorkflow).to receive(:call).with(assessment)
          expect(Assessors::MainAssessor).to receive(:call).with(assessment)
          subject
        end
      end

      context 'non-passported' do
        let(:assessment) { create :assessment, :with_everything }
        it 'returns unprocessable entity' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns errors struct with message' do
          subject
          expect(parsed_response[:success]).to be false
          expect(parsed_response[:errors]).to eq ['Version 1 of the API is not able to process un-passported applications']
        end
      end
    end

    context 'version 1 specified in the header' do
      let(:headers) { { 'Accept' => 'application/json;version=1' } }
      let(:assessment) { create :assessment, :passported }

      it 'returns http success', :show_in_doc do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'returns capital summary data as json' do
        subject
        expect(parsed_response).to eq(JSON.parse(Decorators::ResultDecorator.new(assessment.reload).to_json, symbolize_names: true))
      end
    end

    context 'version 2 specifified in the header' do
      let(:headers) { { 'Accept' => 'application/json;version=2' } }

      context 'non-passported application' do
        let(:assessment) { create :assessment, :with_everything }

        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns capital summary data as json' do
          Timecop.freeze do
            subject
            expected_response = Decorators::AssessmentDecorator.new(assessment.reload).as_json.to_json
            expect(parsed_response).to eq(JSON.parse(expected_response, symbolize_names: true))
          end
        end
      end

      context 'passported application' do
        let(:assessment) { create :assessment, :passported }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns a structure with expected keys' do
          subject
          expect(parsed_response.keys).to eq expected_response_keys
          expect(parsed_response[:assessment].keys).to eq expected_assessment_keys
        end

        it 'returns nil for the income elements of the response' do
          subject
          expect(parsed_response[:assessment][:gross_income]).to be_nil
          expect(parsed_response[:assessment][:disposable_income]).to be_nil
        end
      end
    end

    context 'unknown version' do
      let(:headers) { { 'Accept' => 'application/json;version=9' } }
      let(:assessment) { create :assessment }

      it 'returns unprocessable entity' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors struct with message' do
        subject
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors]).to eq ['Unsupported version specified in AcceptHeader']
      end
    end
  end

  def expected_response_keys
    %i[version timestamp assessment]
  end

  def expected_assessment_keys
    %i[
      id
      client_reference_id
      submission_date
      matter_proceeding_type
      assessment_result
      applicant
      gross_income
      disposable_income
      capital
    ]
  end
end
