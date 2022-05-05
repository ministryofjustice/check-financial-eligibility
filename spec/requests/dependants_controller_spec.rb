require "rails_helper"

RSpec.describe DependantsController, type: :request do
  describe "POST dependants" do
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:dependants_attributes) { attributes_for_list(:dependant, 2) }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:request_payload) do
      {
        dependants: dependants_attributes,
      }
    end

    subject(:post_dependants) { post assessment_dependants_path(assessment_id), params: request_payload.to_json, headers: headers }

    before { post_dependants }

    context "valid payload" do
      it "returns http success", :show_in_doc do
        expect(response).to have_http_status(:success)
      end

      it "generates a valid response" do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "empty payload" do
      let(:request_payload) { {} }

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error payload" do
        expect(parsed_response[:success]).to eq(false)
        expect(parsed_response[:errors]).to contain_exactly("Missing parameter dependants")
      end
    end

    context "invalid assessment_id" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "errors and is shown in apidocs", :show_in_doc do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message", "No such assessment id"
    end

    context "crime payload" do
      let(:assessment) { create :assessment, :criminal }
      let(:assessment_id) { assessment.id }
      let(:dependants_attributes) { attributes_for_list(:dependant, 2, :crime_dependant, :under15) }

      it "returns http success", :show_in_doc do
        expect(response).to have_http_status(:success)
      end

      it "generates a valid response" do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
      end
    end
  end
end
