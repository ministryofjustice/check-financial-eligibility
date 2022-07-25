require "swagger_helper"

RSpec.describe "irregular_incomes", type: :request, swagger_doc: "v4/swagger.yaml" do
  path "/assessments/{assessment_id}/irregular_incomes" do
    post("create irregular_income") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant's irregular income payments to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of irregular income payments",
                  example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                  properties: {
                    payments: {
                      type: :array,
                      required: %i[income_type frequency amount],
                      description: "One or more irregular payment details",
                      items: {
                        type: :object,
                        description: "Irregular payment detail",
                        properties: {
                          income_type: {
                            type: :string,
                            enum: CFEConstants::VALID_IRREGULAR_INCOME_TYPES,
                            description: "Identifying name for this irregular income payment",
                            example: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.first,
                          },
                          frequency: {
                            type: :string,
                            enum: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES,
                            description: "Frequency of the payment received",
                            example: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES.first,
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
            payments: [
              {
                income_type: "student_loan",
                frequency: "annual",
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

      # response(422, "Unprocessable Entity") do
      #   let(:assessment_id) { create(:assessment, :with_gross_income_summary).id }
      #
      #   let(:params) do
      #     {
      #       payments: [
      #         {
      #           frequency: "annual",
      #           amount: 123_456.78,
      #         },
      #       ],
      #     }
      #   end
      #
      #   run_test! do |response|
      #     body = JSON.parse(response.body, symbolize_names: true)
      #     expect(body[:errors]).to include(/Missing parameter income_type/)
      #   end
      # end
    end
  end
end
