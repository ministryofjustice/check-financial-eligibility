require "rails_helper"

RSpec.describe AssessmentsController, type: :request do
  before do
    create :bank_holiday
    mock_lfa_responses
  end

  describe "POST assessments" do
    let(:ipaddr) { "127.0.0.1" }
    let(:ccms_codes) { %w[DA005 SE003 SE014] }

    context "version 5" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "Accept" => "application/json; version=5",
        }
      end
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
        }
      end

      it "calls the assessment creator with version and params" do
        expect(Creators::AssessmentCreator).to receive(:call).with(remote_ip: ipaddr, assessment_params: params.to_json, version: "5").and_call_original
        post assessments_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(parsed_response[:success]).to be true
      end
    end

    context "invalid version" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "Accept" => "application/json; version=1",
        }
      end
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
        }
      end

      it "returns error" do
        post assessments_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors]).to eq ["Version not valid in Accept header"]
      end
    end

    context "no version specified" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "Accept" => "application/json",
        }
      end
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
        }
      end

      it "calls the assessment creator with the default version 5 and params" do
        expect(Creators::AssessmentCreator).to receive(:call).with(remote_ip: ipaddr, assessment_params: params.to_json, version: "5").and_call_original
        post assessments_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(parsed_response[:success]).to be true
      end
    end
  end

  describe "GET /assessments/:id" do
    let(:option) { :below_lower_threshold }
    let(:now) { Time.zone.now }

    subject(:get_assessment) { get assessment_path(assessment), headers: }

    context "calling the correct workflows assessors and decorators" do
      before do
        allow(Assessment).to receive(:find).with(assessment.id.to_s).and_return(assessment)
        allow(Workflows::MainWorkflow).to receive(:call).with(assessment)
        allow(Assessors::MainAssessor).to receive(:call).with(assessment)
      end

      let(:assessment) { create :assessment, :passported, :with_everything }

      context "version 5" do
        let(:decorator) { instance_double Decorators::V5::AssessmentDecorator }

        it "calls the required services and uses the V5 decorator" do
          allow(Decorators::V5::AssessmentDecorator).to receive(:new).with(assessment).and_return(decorator)
          allow(decorator).to receive(:as_json).and_return("")

          get_assessment
        end
      end
    end

    context "untrapped error during processing" do
      let(:assessment) { create :assessment, :with_everything }

      it "call sentry and returns error response" do
        allow(Assessors::MainAssessor).to receive(:call).and_raise(RuntimeError, "Oops")
        expect(Sentry).to receive(:capture_exception)
        get_assessment
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors].first).to match(/^RuntimeError: Oops/)
      end
    end

    context "assessment hasn't been fully completed" do
      let(:assessment) { create :assessment, proceedings: [] } # create assessment without proceedings or applicant
      let(:error_payload) do
        {
          errors: ["You must add proceeding types and applicant to before calling for the assessment to be calculated"],
          success: false,
        }.to_json
      end

      context "without proceedings" do
        let(:assessment) { create :assessment, proceedings: [] } # create assessment without proceedings or applicant

        it "returns error payload" do
          get_assessment
          expect(response.body).to eq error_payload
        end

        it "returns status 422" do
          expect(get_assessment).to eq 422
        end
      end

      context "with proceeding but without applicant" do
        let(:assessment) { create :assessment } # has proceedings but no applicant

        it "returns error payload" do
          get_assessment
          expect(response.body).to eq error_payload
        end

        it "returns status 422" do
          expect(get_assessment).to eq 422
        end
      end
    end
  end
end
