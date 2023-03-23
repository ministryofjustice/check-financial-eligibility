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

    subject(:post_dependants) { post assessment_dependants_path(assessment_id), params: request_payload.to_json, headers: }

    before { post_dependants }

    context "with valid payload" do
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "generates a valid response" do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "with empty payload" do
      let(:request_payload) { {} }

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error payload" do
        expect(parsed_response[:success]).to eq(false)
        expect(parsed_response[:errors]).to include(/The property '#\/' did not contain a required property of 'dependants'/)
      end
    end

    context "with invalid payload" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2, in_full_time_education: nil) }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message",
                      /The property '#\/dependants\/0\/in_full_time_education' of type null did not match the following type: boolean/
    end

    context "missing dependant date_of_birth" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |dependant| dependant.tap { |item| item.delete(:date_of_birth) } } }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message",
                      /The property '#\/dependants\/0' did not contain a required property of 'date_of_birth'/
    end

    context "with missing dependant in_full_time_education" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |dependant| dependant.tap { |item| item.delete(:in_full_time_education) } } }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message",
                      /The property '#\/dependants\/0' did not contain a required property of 'in_full_time_education'/
    end

    context "with missing dependant relationship" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |dependant| dependant.tap { |item| item.delete(:relationship) } } }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message",
                      /The property '#\/dependants\/0' did not contain a required property of 'relationship'/
    end

    context "with invalid dependant relationship" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2, relationship: "son") }

      it "returns an error" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message",
                      /The property '#\/dependants\/0\/relationship' value "son" did not match one of the following values: adult_relative, child_relative/
    end

    context "with no dependant monthly_income" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |dependant| dependant.tap { |item| item.delete(:monthly_income) } } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "generates a valid response" do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "with no dependant assets_value" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |dependant| dependant.tap { |item| item.delete(:assets_value) } } }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "generates a valid response" do
        expect(parsed_response[:success]).to eq(true)
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "with invalid assessment_id" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "it fails with message", "No such assessment id"
    end
  end
end
