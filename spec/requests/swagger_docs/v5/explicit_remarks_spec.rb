require "swagger_helper"

RSpec.describe "explicit_remarks", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/explicit_remarks" do
    post("create explicit_remark") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Add explicit remarks to an assessment
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[explicit_remarks],
                  example: { explicit_remarks: [{ category: "policy_disregards", details: %w[employment charity] }] },
                  properties: {
                    explicit_remarks: {
                      type: :array,
                      description: "One or more remarks by category",
                      items: {
                        type: :object,
                        required: %i[category details],
                        description: "Explicit remark",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_REMARK_CATEGORIES,
                            description: "Category of remark. Currently, only 'policy_disregard' is supported",
                            example: CFEConstants::VALID_REMARK_CATEGORIES.first,
                          },
                          details: {
                            type: :array,
                            description: "One or more remarks for that category",
                            items: {
                              type: :string,
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
          {
            explicit_remarks: [
              {
                category: "policy_disregards",
                details: %w[
                  employment
                  charity
                ],
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
            explicit_remarks: [
              {
                category: "foobar",
                details: %w[
                  employment
                  charity
                ],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(%r{The property '#/explicit_remarks/0/category' value "foobar" did not match one of the following values: policy_disregards})
        end
      end
    end
  end
end
