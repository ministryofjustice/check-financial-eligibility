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

    context "with invalid irregular income" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          irregular_incomes: [
            {
              income_type: "unknown thing",
              frequency: "quarterly",
              amount: 101.01,
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/unknown thing/)
      end

      it "does not create a payment" do
        expect(IrregularIncomePayment.count).to eq(0)
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
        expect(parsed_response[:errors]).to include(/The property '#\/capitals\/bank_accounts\/0' did not contain a required property of 'description'/)
      end
    end

    context "with outgoings" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth: "1980-11-20",
            employed: false,
          },
          irregular_incomes: [
            {
              income_type: "student_loan",
              frequency: "annual",
              amount: "102.34",
            },
          ],
          regular_transactions: [
            {
              category: "friends_or_family",
              amount: "12.34",
              operation: "credit",
              frequency: "weekly",
            },
          ],
          vehicles: [
            {
              value: "560.0",
              date_of_purchase: "2011-06-09",
              loan_amount_outstanding: "234",
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
