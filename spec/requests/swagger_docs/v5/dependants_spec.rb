require "swagger_helper"

RSpec.describe "dependants", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/dependants" do
    post("create dependant") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Adds details of an applicant's dependants.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[dependants],
                  description: "A set dependants details",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/dependants.json"))),
                  properties: {
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: {
                        type: :object,
                        required: %i[date_of_birth in_full_time_education relationship],
                        properties: {
                          date_of_birth: {
                            type: :string,
                            format: :date,
                            example: "1992-07-22",
                          },
                          in_full_time_education: {
                            type: :boolean,
                            example: false,
                            description: "Dependant is in full time education or not",
                          },
                          relationship: {
                            type: :string,
                            enum: Dependant.relationships.values,
                            example: Dependant.relationships.values.first,
                            description: "Dependant's relationship to the applicant",
                          },
                          monthly_income: {
                            "$ref" => "#/components/schemas/currency",
                            description: "Dependant's monthly income",
                          },
                          assets_value: {
                            "$ref" => "#/components/schemas/currency",
                            description: "Dependant's total assets value",
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
            dependants: [
              {
                date_of_birth: "1983-08-08",
                in_full_time_education: false,
                relationship: "adult_relative",
                monthly_income: 4448.63,
                assets_value: 0.0,
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
            dependants: [
              {
                date_of_birth: "1983-08-08",
                in_full_time_education: nil,
                relationship: "adult_relative",
                monthly_income: 4448.63,
                assets_value: 0.0,
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/dependants\/0\/in_full_time_education' of type null did not match the following type: boolean in schema/)
        end
      end
    end
  end
end
