require "swagger_helper"

RSpec.describe "employments", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/employments" do
    post("create employment") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description << "Add applicant employment income to an assessment."

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
                      items: {
                        type: :object,
                        additionalProperties: false,
                        required: %i[name client_id payments],
                        properties: {
                          name: { type: :string },
                          client_id: { type: :string },
                          receiving_only_statutory_sick_or_maternity_pay: { type: :boolean },
                          payments: { "$ref" => "#/components/schemas/EmploymentPaymentList" },
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
