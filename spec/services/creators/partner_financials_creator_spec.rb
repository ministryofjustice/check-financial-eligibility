require "rails_helper"

module Creators
  RSpec.describe PartnerFinancialsCreator do
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:date_of_birth) { Faker::Date.backward.to_s }
    let(:partner_financials_params) do
      {
        partner: {
          date_of_birth:,
          employed: true,
        },
      }
    end

    subject(:creator) { described_class.call(assessment_id:, partner_financials_params:) }

    describe ".call" do
      context "with valid basic partner payload" do
        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates an applicant" do
          expect { creator }.to change(Partner, :count).by 1
        end

        it "returns an empty error array" do
          expect(creator.errors).to be_empty
        end
      end

      context "with invalid basic partner payload" do
        context "date of birth cannot be in future" do
          let(:date_of_birth) { Date.tomorrow.to_date.to_s }

          it "flags self as false" do
            expect(creator.success?).to be false
          end

          it "returns error" do
            expect(creator.errors.size).to eq 1
            expect(creator.errors[0]).to eq "Date of birth cannot be in the future"
          end

          it "does not create a Partner" do
            expect { creator }.not_to change(Partner, :count)
          end
        end

        context "assessment id does not exist" do
          let(:assessment_id) { SecureRandom.uuid }

          it "returns an error" do
            expect(creator.errors).to eq ["No such assessment id"]
          end
        end

        context "partner already exists" do
          before { create :partner, assessment: }

          it "signals failure" do
            expect(creator.success?).to be false
          end

          it "returns error" do
            expect(creator.errors[0]).to eq "There is already a partner for this assesssment"
          end
        end
      end

      context "with valid irregular income" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            irregular_incomes: [
              {
                income_type: "unspecified_source",
                frequency: "monthly",
                amount: 101.01,
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates an income object" do
          creator
          expect(assessment.partner_gross_income_summary.irregular_income_payments.count).to eq 1
        end
      end

      context "with valid employment" do
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
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                  {
                    client_id: "employment-1-payment-2",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                  {
                    client_id: "employment-1-payment-3",
                    date: "2021-10-30",
                    gross: 1046.00,
                    benefits_in_kind: 16.60,
                    tax: -104.10,
                    national_insurance: -18.66,
                  },
                ],
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates an employment object" do
          creator
          expect(assessment.partner_employments.count).to eq 1
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
          expect(creator.errors.join).to include("gross")
          expect(creator.errors.join).to include("benefits_in_kind")
          expect(creator.errors.join).to include("tax")
        end

        it "does not create an employment" do
          expect { creator }.not_to change(Employment, :count)
        end
      end

      context "with valid regular transactions" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            regular_transactions: [
              {
                category: "benefits",
                operation: "credit",
                amount: 9.99,
                frequency: "monthly",
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates a transaction object" do
          creator
          expect(assessment.partner_gross_income_summary.regular_transactions.count).to eq 1
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
          expect(creator.errors[0]).to include("ribbit")
        end

        it "does not create any transactions" do
          expect { creator }.not_to change(RegularTransaction, :count)
        end
      end

      context "with valid state benefits" do
        let(:state_benefit_type) { create :state_benefit_type }
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            state_benefits: [
              {
                name: state_benefit_type.label,
                payments: [
                  { date: 3.days.ago.to_date.to_s, amount: 266.95, client_id: "abc123" },
                ],
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates a benefit object" do
          creator
          expect(assessment.partner_gross_income_summary.state_benefits.count).to eq 1
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
          expect(creator.errors[0]).to include("name")
        end

        it "does not create any benefits" do
          expect { creator }.not_to change(StateBenefit, :count)
        end
      end

      context "with valid properties" do
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
                percentage_owned: 99,
                shared_with_housing_assoc: false,
                subject_matter_of_dispute: false,
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates a property object" do
          creator
          expect(assessment.partner_capital_summary.properties.count).to eq 1
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
          expect(creator.errors[0]).to include("percentage_owned")
        end

        it "does not create any properties" do
          expect { creator }.not_to change(Property, :count)
        end
      end

      context "with valid capitals" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            capitals: {
              bank_accounts: [
                {
                  description: "A",
                  value: 100.1,
                  subject_matter_of_dispute: false,
                },
              ],
              non_liquid_capital: [],
            },
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates capital objects" do
          creator
          expect(assessment.partner_capital_summary.liquid_capital_items.count).to eq 1
        end
      end

      context "with valid vehicles" do
        let(:partner_financials_params) do
          {
            partner: {
              date_of_birth:,
              employed: true,
            },
            vehicles: [
              {
                value: 5000,
                in_regular_use: true,
                date_of_purchase: 1.year.ago.to_date.to_s,
                loan_amount_outstanding: 0,
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates vehicles" do
          creator
          expect(assessment.partner_capital_summary.vehicles.count).to eq 1
        end
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
                value: 5000,
              },
            ],
          }
        end

        it "returns error" do
          expect(creator.errors[0]).to include("date_of_purchase")
        end

        it "does not create any vehicles" do
          expect { creator }.not_to change(Vehicle, :count)
        end
      end

      context "with valid dependants" do
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
                relationship: "child_relative",
              },
            ],
          }
        end

        it "returns a success status flag" do
          expect(creator.success?).to be true
        end

        it "creates dependants" do
          creator
          expect(assessment.partner_dependants.count).to eq 1
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
          expect(creator.errors[0]).to include("relationship")
        end

        it "does not create any dependants" do
          expect { creator }.not_to change(Dependant, :count)
        end
      end
    end
  end
end
