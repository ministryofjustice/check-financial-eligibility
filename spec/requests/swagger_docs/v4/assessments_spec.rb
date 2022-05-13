require "swagger_helper"

RSpec.describe "Assessments", type: :request, vcr: true, swagger_doc: "v4/swagger.yaml" do
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
                      example: Time.zone.now.to_date.iso8601,
                    },
                    matter_proceeding_type: {
                      type: :string,
                      description: "Matter type of the case (v3 and below only)",
                      example: Assessment.matter_proceeding_types.values.first,
                    },
                    proceeding_types: {
                      type: :object,
                      description: "Details of proceeding types in the application (v4 and above only)",
                      properties: {
                        ccms_codes: {
                          type: :array,
                          description: "Array of proceeding type CCMS codes",
                          example: %w[DA001 SE013],
                          items: {
                            type: :string,
                            example: "SE003",
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:params) do
          {
            client_reference_id: "LA-FOO-BAR",
            submission_date: Time.zone.now.to_date.iso8601,
            matter_proceeding_type: Assessment.matter_proceeding_types.values.first,
            proceeding_types: { ccms_codes: %w[DA001] },
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
