require "rails_helper"

RSpec.describe ApplicantsController, type: :request do
  describe "POST applicants" do
    let(:assessment) { create :assessment }
    let(:applicant) { "applicant" }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:params) do
      {
        applicant: {
          date_of_birth: 20.years.ago.to_date,
          has_partner_opponent: false,
          involvement_type: "applicant",
          receives_qualifying_benefit: true,
          employed: false,
        },
      }
    end

    context "with valid payload" do
      before do
        post assessment_applicant_path(assessment.id), params: params.to_json, headers:
      end

      context "when service returns success" do
        it "returns success"  do
          expect(response).to have_http_status(:success)
        end

        it "returns expected response" do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end
      end

      context "when service returns failure" do
        let(:future_date) { 4.years.from_now.to_date }
        let(:future_date_string) { future_date.strftime("%Y-%m-%d") }
        let(:params) do
          {
            assessment_id: assessment.id,
            applicant: {
              date_of_birth: future_date,
              has_partner_opponent: false,
              involvement_type: "applicant",
              receives_qualifying_benefit: true,
            },
          }
        end
        let(:expected_message) do
          %(Date of birth cannot be in future)
        end

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns expected response" do
          expect(parsed_response[:success]).to eq(false)
          expect(parsed_response[:errors]).to eq [expected_message]
        end
      end
    end

    context "with non existent assessment id" do
      let(:non_existent_assessment_id) { SecureRandom.uuid }

      before do
        params[:assessment_id] = non_existent_assessment_id
        post assessment_applicant_path(non_existent_assessment_id), params: params.to_json, headers:
      end

      it_behaves_like "it fails with message", "No such assessment id"
    end

    context "with employed of null" do
      let(:params) do
        {
          applicant: {
            date_of_birth: 20.years.ago.to_date,
            has_partner_opponent: false,
            involvement_type: "applicant",
            receives_qualifying_benefit: true,
            employed: nil,
          },
        }
      end

      before do
        post assessment_applicant_path(assessment.id), params: params.to_json, headers:
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with malformed JSON payload" do
      context "missing applicant" do
        before do
          params.delete(:applicant)
          post assessment_applicant_path(assessment.id), params: params.to_json, headers:
        end

        it_behaves_like "it fails with message", /The property '#\/' did not contain a required property of 'applicant'/
      end

      context "with invalid date of birth" do
        let(:dob) { "2002-12-32" }

        before do
          params[:applicant][:date_of_birth] = dob
          post assessment_applicant_path(assessment.id), params: params.to_json, headers:
        end

        it_behaves_like "it fails with message", /The property '#\/applicant\/date_of_birth' value "2002-12-32" did not match the regex/
      end

      context "has_partner_opponent not a boolean" do
        before do
          params[:applicant][:has_partner_opponent] = "yes"
          post assessment_applicant_path(assessment.id), params: params.to_json, headers:
        end

        it_behaves_like "it fails with message",
                        /The property '#\/applicant\/has_partner_opponent' of type string did not match the following type: boolean in schema/
      end

      context "with non boolean receives_qualifying_benefit" do
        it "fails with a message" do
          params[:applicant][:receives_qualifying_benefit] = "yes"
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with date of birth in the future" do
        let(:dob) { 3.days.from_now.to_date }

        before do
          params[:applicant][:date_of_birth] = dob
          post assessment_applicant_path(assessment.id), params: params.to_json, headers:
        end

        it_behaves_like "it fails with message", /Date of birth cannot be in future/
      end
    end
  end
end
