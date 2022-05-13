require "swagger_helper"

RSpec.describe "state_benefit_type", type: :request do
  path "/state_benefit_type" do
    get("list state_benefit_types") do
      response(200, "successful") do
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
