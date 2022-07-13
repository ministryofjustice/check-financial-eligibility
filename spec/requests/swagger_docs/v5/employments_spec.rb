require "swagger_helper"

RSpec.describe "employments", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/employments" do
    post("create employment") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant employment income to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "One or more employments incomes",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/employments.json"))),
                  properties: {
                    employment_income: {
                      type: :array,
                      required: %i[name client_id payments],
                      description: "One or more employment income details",
                      items: {
                        type: :object,
                        description: "Employment income detail",
                        properties: {
                          name: {
                            type: :string,
                            description: "Identifying name for this employment - e.g. employer's name",
                          },
                          client_id: {
                            type: :string,
                            description: "Client supplied id to identify the employment",
                          },
                          payments: {
                            type: :array,
                            required: %i[client_id date gross benefits_in_kind tax national_insurance net_employment_income],
                            description: "One or more employment payment details",
                            items: {
                              type: :object,
                              description: "Employment payment detail",
                              properties: {
                                client_id: {
                                  type: :string,
                                  description: "Client supplied id to identify the payment",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                                date: {
                                  type: :string,
                                  format: :date,
                                  description: "Date payment received",
                                  example: "1992-07-22",
                                },
                                gross: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Gross payment income received",
                                  example: "101.01",
                                },
                                benefits_in_kind: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Benefit in kind amount received",
                                },
                                tax: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Amount of tax paid",
                                },
                                national_insurance: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Amount of national insurance paid",
                                },
                                net_employment_income: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Net payment income received",
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
          JSON.parse(file_fixture("employments.json").read)
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
            employment_income: [
              {
                client_id: "1fb3fdce-5525-4dcd-b81b-fc860f82fef4",
                payments: [
                  {
                    client_id: "e46055be-72b7-4000-8409-f077e2fc5bce",
                    date: "2021-10-30",
                    gross: 1046.0,
                    benefits_in_kind: 16.6,
                    tax: -104.1,
                    national_insurance: -18.66,
                    net_employment_income: 898.84,
                  },
                ],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/employment_income\/0' did not contain a required property of 'name'/)
        end
      end
    end
  end
end
