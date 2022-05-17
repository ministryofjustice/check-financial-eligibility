require "rails_helper"
require "swagger_helper"

RSpec.describe "applicants", type: :request, swagger_doc: "v4/swagger.yaml" do
  path "/assessments/{assessment_id}/applicant" do
    post("create applicant") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION
        This endpoint will create an Applicant and associate it with
        an existing Assessment which has been created via `POST /assessments`
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    applicant: {
                      type: :object,
                      description: "Object describing pertinent applicant details",
                      properties: {
                        date_of_birth: { type: :string,
                                         format: :date,
                                         example: "1992-07-22",
                                         description: "Applicant date of birth" },
                        involvement_type: { type: :string,
                                            enum: Applicant.involvement_types.values,
                                            example: Applicant.involvement_types.values.first,
                                            description: "Applicant involvement type" },
                        has_partner_opponent: { type: :boolean,
                                                example: false,
                                                description: "Applicant has partner opponent" },
                        receives_qualifying_benefit: { type: :boolean,
                                                       example: false,
                                                       description: "Applicant receives qualifying benefit" },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          {
            applicant: {
              date_of_birth: "1992-07-22",
              involvement_type: "applicant",
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
    end
  end
end
