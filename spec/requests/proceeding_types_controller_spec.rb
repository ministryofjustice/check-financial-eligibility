require "rails_helper"

RSpec.describe ProceedingTypesController, type: :request do
  describe "POST proceeding types" do
    let(:assessment) { create :assessment }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:mock_creator) { instance_double(Creators::ProceedingTypesCreator, success?: mock_response, errors: mock_errors) }
    let(:payload) do
      {
        proceeding_types: [
          {
            ccms_code: "DA001",
            client_involvement_type: "A",
          },
          {
            ccms_code: "SE014",
            client_involvement_type: "Z",
          },
        ],
      }
    end
    let(:params) do
      {
        assessment_id: assessment.id,
        proceeding_types_params: payload,
      }
    end

    before do
      allow(Creators::ProceedingTypesCreator).to receive(:call).with(params).and_return(mock_creator)
      post assessment_proceeding_types_path(assessment.id), params: payload.to_json, headers:
    end

    context "sucessful creation" do
      let(:mock_response) { true }
      let(:mock_errors) { [] }

      it "returns 200 success" do
        expect(response).to have_http_status(:success)
      end

      it "returns expected payload" do
        expect(JSON.parse(response.body)).to eq({ "success" => true, "errors" => [] })
      end
    end

    context "failed creation" do
      let(:mock_response) { false }
      let(:mock_errors) { ["dummy error message"] }

      it "returns 422 unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns expected payload" do
        expect(JSON.parse(response.body)).to eq({ "success" => false, "errors" => ["dummy error message"] })
      end
    end
  end
end
