require "swagger_helper"

RSpec.describe "outgoings", type: :request, swagger_doc: "v3/swagger.yaml" do
  path "/assessments/{assessment_id}/outgoings" do
    post("create outgoing") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant's outgoings to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of outgoings sources",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/outgoings.json"))),
                  properties: {
                    outgoings: {
                      type: :array,
                      description: "One or more outgoings categorized by name",
                      items: {
                        type: :object,
                        description: "Outgoing payments detail",
                        required: true,
                        properties: {
                          name: {
                            type: :string,
                            enum: CFEConstants::VALID_OUTGOING_CATEGORIES,
                            required: true,
                            description: "Type of outgoing",
                            example: CFEConstants::VALID_OUTGOING_CATEGORIES.first,
                          },
                          payments: {
                            type: :array,
                            description: "One or more outgoing payments detail",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                payment_date: {
                                  type: :string,
                                  format: :date,
                                  required: true,
                                  description: "Date payment made",
                                  example: "1992-07-22",
                                },
                                housing_costs_type: {
                                  type: :string,
                                  enum: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES,
                                  required: false,
                                  description: "Housing cost type (omit for non-housing cost outgoings)",
                                  example: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES.first,
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  required: true,
                                  description: "Amount of payment made",
                                  example: 101.01,
                                },
                                client_id: {
                                  type: :string,
                                  format: :uuid,
                                  required: true,
                                  description: "Client identifier for outgoing payment",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          JSON.parse(file_fixture("outgoings.json").read)
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
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          {
            outgoings: [
              {
                name: "foobar",
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/Invalid parameter 'name' value/)
        end
      end
    end
  end
end
