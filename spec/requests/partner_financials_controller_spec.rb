require "rails_helper"

describe PartnerFinancialsController, :calls_bank_holiday, type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:assessment) { create :assessment, :with_applicant, :with_disposable_income_summary, :with_gross_income_summary, :with_capital_summary }
  let(:date_of_birth) { Faker::Date.backward.to_s }

  describe "POST /assessments/:assessment_id/partner_financials" do
    before do
      post assessment_partner_financials_path(assessment), params: partner_financials_params.to_json, headers:
    end

    context "with employment values as strings" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          employments: [
            {
              name: "Job",
              client_id: "Something",
              payments: [
                {
                  client_id: "Client",
                  date: "2022-05-04",
                  gross: "1046.45",
                  benefits_in_kind: "12.34",
                  tax: "-34.23",
                  national_insurance: "-12.56",
                },
              ],
            },
          ],
        }
      end

      it "does not error" do
        expect(response).to be_successful
      end
    end

    context "with vehicle from the future" do
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

    context "with vehicle missing date of purchase" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          vehicles: [
            {
              value: 5000,
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/date_of_purchase/)
      end

      it "does not create any vehicles" do
        expect(Vehicle.count).to eq(0)
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

    context "with invalid regular transactions" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          regular_transactions: [
            {
              category: "benefits",
              operation: "ribbit",
              amount: 9.99,
              frequency: "monthly",
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/ribbit/)
      end

      it "does not create any transactions" do
        expect(RegularTransaction.count).to eq(0)
      end
    end

    context "with invalid state benefits" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          state_benefits: [
            {
              payments: [
                { date: 3.days.ago.to_date, amount: 266.95, client_id: "abc123" },
              ],
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/name/)
      end

      it "does not create any benefits" do
        expect(StateBenefit.count).to eq(0)
      end
    end

    context "with invalid dependants" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          dependants: [
            {
              in_full_time_education: false,
              date_of_birth: 1.year.ago.to_date.to_s,
              relationship: "quirky",
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors]).to include(/relationship/)
      end

      it "does not create any dependants" do
        expect(Dependant.count).to eq(0)
      end
    end

    context "with invalid employment" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          employments: [
            {
              name: "Job 1",
              client_id: "employment-id-1",
              payments: [
                {
                  client_id: "employment-1-payment-1",
                  date: "2021-10-30",
                  national_insurance: -18.66,
                },
              ],
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors].join).to include("gross")
        expect(parsed_response[:errors].join).to include("benefits_in_kind")
        expect(parsed_response[:errors].join).to include("tax")
      end

      it "does not create an employment" do
        expect(Employment.count).to eq(0)
      end
    end

    context "with invalid additional_properties" do
      let(:partner_financials_params) do
        {
          partner: {
            date_of_birth:,
            employed: true,
          },
          additional_properties: [
            {
              value: 1_000,
              outstanding_mortgage: 0,
              shared_with_housing_assoc: false,
              subject_matter_of_dispute: false,
            },
          ],
        }
      end

      it "returns error" do
        expect(parsed_response[:errors][0]).to include("percentage_owned")
      end

      it "does not create any properties" do
        expect(Property.count).to eq(0)
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
