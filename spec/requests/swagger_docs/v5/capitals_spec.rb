require "swagger_helper"

RSpec.describe "capitals", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/capitals" do
    post("create capital") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        Adds details of an applicant's capital assets to an assessment.

        There are two types of assets:

        - bank_accounts The description should hold the Bank name and account
          number, and the value should hold the lowest balance during that calculation period (i.e. the
          month leading up to the submission date)

        - non-liquid capital items: These are other capital assets which are not immediately realisable as cash, such
          as stocks and shares, interest in a trust, valuable items, etc. Do not include property or vehicles which
          are added through separate endpoints.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    bank_accounts: {
                      type: :array,
                      description: "One or more account details",
                      example: [{ value: 1.01, description: "test name 1" }, { value: 100.01, description: "test name 2" }],
                      items: {
                        type: :object,
                        description: "Account detail",
                        properties: {
                          value: {
                            type: :number,
                            format: :decimal,
                          },
                          description: {
                            type: :string,
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          {
            bank_accounts: [
              {
                description: "ALKEN ASSET MANAGEMENT 10606062",
                value: 85_847.05,
              },
              {
                description: "SANTANDER UK PLC 68346475",
                value: 59_389.67,
              },
            ],
            non_liquid_capital: [
              {
                description: "FTSE tracker unit trust",
                value: 61_192.56,
              },
              {
                description: "Aramco shares",
                value: 51_082.81,
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
        let(:assessment_id) { create(:assessment, :with_capital_summary).id }

        let(:params) do
          {
            bank_accounts: [
              {
                description: "ALKEN ASSET MANAGEMENT 10606062",
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/bank_accounts\/0' did not contain a required property of 'value'/)
        end
      end
    end
  end
end
