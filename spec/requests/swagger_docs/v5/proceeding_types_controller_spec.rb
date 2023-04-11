require "swagger_helper"

RSpec.describe "proceeding_types", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/proceeding_types" do
    post("create ") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Adds details of an application's proceeding types.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[proceeding_types],
                  description: "A set of proceeding_type details",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/proceeding_types.json"))),
                  properties: {
                    proceeding_types: {
                      type: :array,
                      minItems: 1,
                      description: "One or more proceeding_type details",
                      items: {
                        type: :object,
                        required: %i[ccms_code client_involvement_type],
                        properties: {
                          ccms_code: {
                            type: :string,
                            enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                            example: "DA001",
                            description: "The code expected by CCMS",
                          },
                          client_involvement_type: {
                            type: :string,
                            enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                            example: "A",
                            description: "The client_involvement_type expected by CCMS",
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          {
            proceeding_types: [
              {
                ccms_code: "DA001",
                client_involvement_type: "A",
              },
            ],
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

      response(422, "Unprocessable Entity") do\
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          {
            proceeding_types: [
              {
                ccms_code: "DA001",
                client_involvement_type: "X",
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/proceeding_types\/0\/client_involvement_type' value "X" did not match one of the following values: A, D, W, Z, I in schema/)
        end
      end
    end
  end
end
