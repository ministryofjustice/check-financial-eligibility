require "swagger_helper"

RSpec.describe "state_benefits", type: :request, swagger_doc: "v4/swagger.yaml" do
  path "/assessments/{assessment_id}/state_benefits" do
    post("create state_benefit") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant's state benefits to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of other regular income sources",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/state_benefits.json"))),
                  properties: {
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits receved by the applicant and categorized by name",
                      items: {
                        type: :object,
                        description: "State benefit payment detail",
                        properties: {
                          name: {
                            type: :string,
                            description: "Name of the state benefit",
                            example: "my_state_bnefit",
                          },
                          payments: {
                            type: :array,
                            description: "One or more state benefit payments details",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                date: {
                                  type: :string,
                                  format: :date,
                                  required: true,
                                  description: "Date payment received",
                                  example: "1992-07-22",
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  required: true,
                                  description: "Amount of payment received",
                                  example: 101.01,
                                },
                                client_id: {
                                  type: :string,
                                  format: :uuid,
                                  required: true,
                                  description: "Client identifier for payment received",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                                flags: {
                                  type: :object,
                                  required: false,
                                  description: "Line items that should be flagged to caseworkers for review",
                                  example: { multi_benefit: true },
                                  properties: {
                                    multi_benefit: {
                                      type: :boolean,
                                    },
                                  },
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        before { create(:state_benefit_type, :other) }

        let(:params) do
          JSON.parse(file_fixture("state_benefits.json").read)
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            state_benefits: [
              {
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/Missing parameter name/)
        end
      end
    end
  end
end
