require "swagger_helper"

RSpec.describe "cash_transactions", type: :request, swagger_doc: "v4/swagger.yaml" do
  path "/assessments/{assessment_id}/cash_transactions" do
    post("create cash_transaction") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add cash income and outgoings to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of cash income[ings] and outgoings payments by category",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/cash_transactions.json"))
                                          .gsub("3.months.ago", "2022-01-01")
                                          .gsub("2.months.ago", "2022-02-01")
                                          .gsub("1.month.ago", "2022-03-01")),
                  properties: {
                    income: {
                      type: :array,
                      description: "One or more income details",
                      items: {
                        type: :object,
                        description: "Income detail",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_INCOME_CATEGORIES,
                            example: CFEConstants::VALID_INCOME_CATEGORIES.first,
                          },
                          payments: {
                            type: :array,
                            description: "One or more payment details",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                date: {
                                  type: :string,
                                  format: :date,
                                  example: "1992-07-22",
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  example: "101.01",
                                },
                                client_id: {
                                  type: :string,
                                  format: :uuid,
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    outgoings: {
                      type: :array,
                      description: "One or more outgoing details",
                      items: {
                        type: :object,
                        description: "Outgoing detail",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_OUTGOING_CATEGORIES,
                            example: CFEConstants::VALID_OUTGOING_CATEGORIES.first,
                          },
                          payments: {
                            type: :array,
                            description: "One or more payment details",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                date: {
                                  type: :string,
                                  format: :date,
                                  example: "1992-07-22",
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  example: "101.02",
                                },
                                client_id: {
                                  type: :string,
                                  format: :uuid,
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          source = file_fixture("cash_transactions.json").read
          updated = source.gsub("3.months.ago", 3.months.ago.beginning_of_month.strftime("%Y-%m-%d"))
                          .gsub("2.months.ago", 2.months.ago.beginning_of_month.strftime("%Y-%m-%d"))
                          .gsub("1.month.ago", 1.month.ago.beginning_of_month.strftime("%Y-%m-%d"))
          JSON.parse(updated)
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            income: [
              {
                category: "maintenance_out",
                payments: [],
              },
            ],
            outgoings: [
              {
                category: "maintenance_in",
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/income\/0\/category' value "maintenance_out" did not match one of the following values/)
          expect(body[:errors]).to include(/The property '#\/outgoings\/0\/category' value "maintenance_in" did not match one of the following values/)
        end
      end
    end
  end
end
