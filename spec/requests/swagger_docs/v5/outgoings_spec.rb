require "swagger_helper"

RSpec.describe "outgoings", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/outgoings" do
    post("create outgoing") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description << "Add applicant's outgoings to an assessment."

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  description: "A set of outgoings sources",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/outgoings.json"))),
                  properties: {
                    outgoings: { "$ref" => "#/components/schemas/OutgoingsList" },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment, :with_disposable_income_summary).id }

        let(:params) do
          JSON.parse(file_fixture("outgoings.json").read)
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

      response(422, "Unprocessable Entity") do
        let(:assessment_id) { create(:assessment).id }

        let(:params) do
          {
            outgoings: [
              {
                name: "foobar",
                payments: [],
              },
            ],
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/outgoings\/0\/name' value "foobar" did not match one of the following values: child_care, rent_or_mortgage, maintenance_out, legal_aid/)
        end
      end
    end
  end
end
