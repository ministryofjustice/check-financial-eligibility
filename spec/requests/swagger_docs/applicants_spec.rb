require "rails_helper"
require "swagger_helper"

RSpec.describe "applicants", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/applicant" do
    post("create applicant") do
      tags "Applicants"
      consumes "application/json"
      produces "application/json"
      parameter name: "assessment_id", in: :path, type: :uuid, description: "assessment_id"
      parameter name: "applicant",
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    date_of_birth: { type: :date,
                                     example: "1992-07-22",
                                     description: "Applicant date of birth" },
                    involvement_type: { type: :string,
                                        example: "applicant",
                                        description: "Applicant involvement type" },
                    has_partner_opponent: { type: :boolean,
                                            example: false,
                                            description: "Applicant has partner opponent" },
                    receives_qualifying_benefit: { type: :boolean,
                                                   example: false,
                                                   description: "Applicant receives qualifying benefit" },
                  },
                }

      response(200, "successful") do
        let!(:assessment) { create :assessment }
        let(:assessment_id) { assessment.id }
        let(:applicant) do
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
