require "swagger_helper"

RSpec.describe "V3 Assessments", type: :request, vcr: true, swagger_doc: "v3/swagger.yaml" do
  path "/assessments" do
    post("create assessment") do
      tags "Assessment"
      consumes "application/json"
      produces "application/json"

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    client_reference_id: {
                      type: :string,
                      example: "LA-FOO-BAR",
                      description: "Client's reference number for this application (free text)",
                    },
                    submission_date: {
                      type: :string,
                      description: "Date of the original submission (iso8601 format)",
                      example: "2022-05-19",
                    },
                    matter_proceeding_type: {
                      type: :string,
                      description: "Matter type of the case (v3 and below only)",
                      example: Assessment.matter_proceeding_types.values.first,
                    },
                  },
                }

      # rubocop:disable RSpec/VariableName
      let(:Accept) { "application/json;version=3" }
      # rubocop:enable RSpec/VariableName

      response(200, "successful") do
        let(:params) do
          {
            submission_date: "2022-05-19",
            matter_proceeding_type: Assessment.matter_proceeding_types.values.first,
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end

      response(422, "Unprocessable Entity") do
        context ""
        let(:params) { {} }

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include("Missing parameter submission_date")
        end
      end
    end
  end

  path "/assessments/{id}" do
    parameter name: :id, in: :path, type: :string, description: "Unique identifier of the assessment"

    get("show assessment") do
      tags "Assessment"
      produces "application/json"

      response(200, "successful") do
        let(:assessment) { create(:assessment, :passported, :with_everything, :with_eligibilities) }
        let(:id) { assessment.id }

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end
    end
  end
end
