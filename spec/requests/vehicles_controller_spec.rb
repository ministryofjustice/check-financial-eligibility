require "rails_helper"

RSpec.describe VehiclesController, type: :request do
  describe "POST /assessments/:assessment_id/vehicles" do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:vehicles) { attributes_for_list(:vehicle, 2) }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:date_in_future) { 3.days.from_now.strftime("%Y-%m-%d") }
    let(:params) { { vehicles: } }

    subject(:post_payload) { post assessment_vehicles_path(assessment), params: params.to_json, headers: }

    it "returns http success", :show_in_doc do
      post_payload
      expect(response).to have_http_status(:success)
    end

    it "creates vehicles" do
      expect { post_payload }.to change { assessment.vehicles.count }.by(2)
    end

    it "sets success flag to true" do
      post_payload
      expect(parsed_response[:success]).to be true
    end

    it "returns blank errors" do
      post_payload
      expect(parsed_response[:errors]).to be_empty
    end

    shared_examples "an unprocessable entity" do |invalid_item|
      before { post_payload }

      it "returns unprocessable" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error information" do
        expect(parsed_response[:errors].join).to match(/Invalid.*#{invalid_item}/)
      end

      it "sets success flag to false" do
        expect(parsed_response[:success]).to be false
      end
    end

    context "with an invalid id" do
      let(:assessment) { 33 }

      it "returns unprocessable", :show_in_doc do
        post_payload
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like "an unprocessable entity", "assessment_id"
    end

    context "with invalid input" do
      let(:vehicles) { :invalid }

      it_behaves_like "an unprocessable entity", "vehicles"
    end

    context "with a future wage slip" do
      let(:vehicles) { [attributes_for(:vehicle, date_of_purchase: date_in_future)] }

      it_behaves_like "an unprocessable entity", "date_of_purchase"
    end

    context "with service returning error" do
      let(:error) { instance_double Creators::VehicleCreator, "success?" => false, errors: ["Invalid: foo"] }

      before { allow(Creators::VehicleCreator).to receive(:call).and_return(error) }

      it_behaves_like "an unprocessable entity", "foo"
    end
  end
end
