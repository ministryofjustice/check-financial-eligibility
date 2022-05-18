require "swagger_helper"

RSpec.describe "properties", type: :request, swagger_doc: "v3/swagger.yaml" do
  path "/assessments/{assessment_id}/properties" do
    post("create property") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Add applicant's properties to an assessment.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set consisting of a main home and additional properties",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/properties.json"))),
                  properties: {
                    properties: {
                      type: :object,
                      description: "A main home and additional properties",
                      properties: {
                        main_home: {
                          type: :object,
                          description: "Applicant's main home details",
                          required: true,
                          properties: {
                            value: {
                              type: :number,
                              format: :decimal,
                              required: true,
                              description: "Financial value of the property",
                              example: 500_000.01,
                            },
                            outstanding_mortgage: {
                              type: :number,
                              format: :decimal,
                              required: true,
                              description: "Amount outstanding on all mortgages against this property",
                              example: 999.99,
                            },
                            percentage_owned: {
                              type: :number,
                              format: :decimal,
                              required: true,
                              description: "Percentage share of the property which is owned by the applicant",
                              example: 99.99,
                            },
                            shared_with_housing_assoc: {
                              type: :boolean,
                              required: true,
                              description: "Property is shared with a housing association",
                            },
                          },
                        },
                        additional_properties: {
                          type: :array,
                          required: false,
                          description: "One or more additional properties owned by the applicant",
                          items: {
                            type: :object,
                            description: "Additional property details",
                            properties: {
                              value: {
                                type: :number,
                                format: :decimal,
                                required: true,
                                description: "Financial value of the property",
                                example: 500_000.01,
                              },
                              outstanding_mortgage: {
                                type: :number,
                                format: :decimal,
                                required: true,
                                description: "Amount outstanding on all mortgages against this property",
                                example: 999.99,
                              },
                              percentage_owned: {
                                type: :number,
                                format: :decimal,
                                required: true,
                                description: "Percentage share of the property which is owned by the applicant",
                                example: 99.99,
                              },
                              shared_with_housing_assoc: {
                                type: :boolean,
                                required: true,
                                description: "Property is shared with a housing association",
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          JSON.parse(file_fixture("properties.json").read)
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
            properties: {
              main_home: {
                value: nil,
                outstanding_mortgage: 999.99,
                percentage_owned: 15.0,
                shared_with_housing_assoc: true,
              },
              additional_properties: [],
            },
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/Invalid parameter 'value' value/)
        end
      end
    end
  end
end
