require "rails_helper"

RSpec.describe ProceedingTypesController, type: :request do
  describe "POST proceeding types" do
    let(:assessment) { create :assessment }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:mock_creator) { instance_double(Creators::ProceedingTypesCreator::Result, success?: mock_response, errors: mock_errors) }
    let(:payload) do
      {
        proceeding_types:,
      }
    end
    let(:params) do
      {
        assessment:,
        proceeding_types_params: payload,
      }
    end

    context "with mock creator" do
      let(:proceeding_types) do
        [
          {
            ccms_code: "DA001",
            client_involvement_type: "A",
          },
          {
            ccms_code: "SE014",
            client_involvement_type: "Z",
          },
        ]
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

    context "with errors" do
      before do
        post assessment_proceeding_types_path(assessment.id), params: payload.to_json, headers:
      end

      context "with invalid client_involvement_type" do
        let(:proceeding_types) { attributes_for_list(:proceeding_type, 1, :with_invalid_client_involvement_type) }

        it "fails" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns an error message" do
          expect(parsed_response[:errors]).to include(/The property '#\/proceeding_types\/0\/client_involvement_type' value "X" did not match one of the following values/)
        end
      end

      context "with invalid ccms_code" do
        let(:proceeding_types) { attributes_for_list(:proceeding_type, 1, :with_invalid_ccms_code) }

        it "fails" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns an error message" do
          expect(parsed_response[:errors]).to include(/The property '#\/proceeding_types\/0\/ccms_code' value "XX1234" did not match one of the following values/)
        end
      end

      context "with duplicate ccms_codes" do
        let(:proceeding_types) do
          [
            {
              ccms_code: "DA001",
              client_involvement_type: "A",
            },
            {
              ccms_code: "DA001",
              client_involvement_type: "I",
            },
          ]
        end

        it "fails" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns an error message" do
          expect(parsed_response[:errors]).to include(/Ccms code has already been taken/)
        end
      end
    end
  end
end
