require "rails_helper"

describe PartnerFinancialsController, :calls_bank_holiday, type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:assessment) { create :assessment, :with_applicant, :with_disposable_income_summary, :with_gross_income_summary, :with_capital_summary }
  let(:date_of_birth) { Faker::Date.backward.to_s }

  describe "POST /assessments/:assessment_id/partner_financials" do
    before do
      post assessment_partner_financials_path(assessment), params: partner_financials_params.to_json, headers:
    end

    context "with invalid vehicles" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          vehicles: [
            {
              date_of_purchase: "2900-07-07",
              value: 2000.0,
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/Date of purchase cannot be in the future/)
      end
    end

    context "with invalid capitals" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          capitals: {
            bank_accounts: [
              {
                value: 2000.0,
              },
            ],
          },
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/The property '#\/bank_accounts\/0' did not contain a required property of 'description'/)
      end
    end

    context "with outgoings" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth: "1980-11-20",
            employed: true,
          },
          "dependants": [
            {
              "date_of_birth": "2022-11-20",
              "in_full_time_education": false,
              "relationship": "child_relative",
              "monthly_income": 0,
              "assets_value": 0,
            },
          ],
          "employments": [
            {
              "name": "job-1-dec",
              "client_id": "job1-id-uuid",
              "payments": [
                {
                  "client_id": "job1-december-pay-uuid",
                  "date": "2020-12-1",
                  "gross": 450.00,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
                {
                  "client_id": "job-1-november-pay-uuid",
                  "date": "2020-11-01",
                  "gross": 450.00,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
                {
                  "client_id": "job-1-october-pay-uuid",
                  "date": "2020-10-01",
                  "gross": 450,
                  "benefits_in_kind": 0,
                  "tax": -10.04,
                  "national_insurance": -5.02,
                },
              ],
            },
          ],
          "outgoings": [
            {
              "name": "rent_or_mortgage",
              "payments": [
                {
                  "payment_date": "2021-05-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id7",
                },
                {
                  "payment_date": "2021-04-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id8",
                },
                {
                  "payment_date": "2021-03-10",
                  "amount": 600,
                  "housing_cost_type": "rent",
                  "client_id": "id9",
                },
              ],
            },
          ],
          "capitals": {
            "bank_accounts": [
              {
                "value": 420,
                "description": "Bank acct 1",
              },
              {
                "value": 200,
                "description": "Bank acct 2",
              },
            ],
          },
        }
      end
      let(:employments) do
        {
          "employment_income": [
            {
              "name": "job-1-dec",
              "client_id": "job1-id-uuid",
              "payments": [
                {
                  "client_id": "job1-december-pay-uuid",
                  "date": "2020-12-18",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.60,
                  "national_insurance": -208.08,
                },
                {
                  "client_id": "job-1-november-pay-uuid",
                  "date": "2020-11-28",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.6,
                  "national_insurance": -208.08,
                },
                {
                  "client_id": "job-1-october-pay-uuid",
                  "date": "2020-10-28",
                  "gross": 2526.00,
                  "benefits_in_kind": 0,
                  "tax": -244.6,
                  "national_insurance": -208.08,
                },
              ],
            },
          ],
        }
      end
      let(:proceeding_types) do
        [
          {
            "ccms_code": "DA001",
            "client_involvement_type": "A",
          },
          {
            "ccms_code": "SE013",
            "client_involvement_type": "A",
          },
          {
            "ccms_code": "SE003",
            "client_involvement_type": "A",
          },
        ]
      end

      before do
        post("/assessments/#{assessment.id}/employments", params: employments.to_json, headers:)
        post("/assessments/#{assessment.id}/proceeding_types", params: proceeding_types.to_json, headers:)

        get("/assessments/#{assessment.id}")
      end

      it "uses the partner outgoings field" do
        expect(parsed_response.dig(:assessment, :partner_disposable_income, :monthly_equivalents, :all_sources))
          .to eq({
            child_care: 0.0, rent_or_mortgage: 600.0, maintenance_out: 0.0, legal_aid: 0.0
          })
      end
    end
  end
end
