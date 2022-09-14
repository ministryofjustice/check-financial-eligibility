require "swagger_helper"

RSpec.describe "regular_transactions", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/regular_transactions" do
    post("create regular_transactions") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant's regular transactions to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of regular transactions",
                  example: {
                    regular_transactions:
                      [
                        { category: "maintenance_in", operation: "credit", frequency: "monthly", amount: 123_456.78 },
                        { category: "maintenance_out", operation: "debit", frequency: "four_weekly", amount: 123_456.78 },
                      ],
                  },
                  properties: {
                    regular_transactions: {
                      type: :array,
                      minItems: 1,
                      required: %i[category operation frequency amount],
                      description: "One or more regular transactions",
                      items: {
                        type: :object,
                        description: "regular transaction detail",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_INCOME_CATEGORIES + CFEConstants::VALID_OUTGOING_CATEGORIES,
                            description: "Identifying category for this regular transaction",
                            example: CFEConstants::VALID_INCOME_CATEGORIES.first,
                          },
                          operation: {
                            type: :string,
                            enum: %w[credit debit],
                            description: "Identifying operation for this regular transaction",
                            example: "credit",
                          },
                          frequency: {
                            type: :string,
                            enum: CFEConstants::VALID_FREQUENCIES,
                            description: "Frequency with which regular transaction is made or received",
                            example: CFEConstants::VALID_FREQUENCIES.first,
                          },
                          amount: {
                            type: :number,
                            format: :decimal,
                            example: 101.01,
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            regular_transactions: [
              {
                category: "maintenance_in",
                operation: "credit",
                frequency: "monthly",
                amount: 123_456.78,
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
        let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }

        let(:params) do
          {
            regular_transactions: [
              {
                category: "",
                operation: "",
                frequency: "",
                amount: "",
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors])
            .to include(%r{The property '#/regular_transactions/0/category' value "" did not match one of the following values:},
                        %r{The property '#/regular_transactions/0/operation' value "" did not match one of the following values: credit, debit},
                        %r{The property '#/regular_transactions/0/frequency' value "" did not match one of the following values: monthly, four_weekly, two_weekly, weekly, unknown},
                        %r{The property '#/regular_transactions/0/amount' value "" did not match the regex})
        end
      end
    end
  end
end
