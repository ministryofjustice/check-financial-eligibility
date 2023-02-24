require "rails_helper"
require "swagger_helper"

RSpec.describe "applicants", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/applicant" do
    post("create applicant") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        This endpoint will create an Applicant and associate it with
        an existing Assessment which has been created via `POST /assessments`
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[date_of_birth has_partner_opponent receives_qualifying_benefit],
                  properties: {
                    applicant: {
                      type: :object,
                      description: "Object describing pertinent applicant details",
                      properties: {
                        date_of_birth: { type: :string,
                                         format: :date,
                                         example: "1992-07-22",
                                         description: "Applicant date of birth" },
                        has_partner_opponent: { type: :boolean,
                                                example: false,
                                                description: "Applicant has partner opponent" },
                        receives_qualifying_benefit: { type: :boolean,
                                                       example: false,
                                                       description: "Applicant receives qualifying benefit" },
                        receives_asylum_support: { type: :boolean,
                                                   example: false,
                                                   description: "Applicant receives section 4 or section 95 Asylum Support" },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, version: "5").id }

        let(:params) do
          {
            applicant: {
              date_of_birth: "1992-07-22",
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
            },
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
        let(:assessment_id) { create(:assessment, version: "5").id }

        let(:params) do
          {
            applicant: {
              has_partner_opponent: false,
              receives_qualifying_benefit: true,
            },
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/applicant' did not contain a required property of 'date_of_birth' in schema file:/)
        end
      end
    end
  end
end
