require "rails_helper"

module V2
  RSpec.describe AssessmentsController, type: :request do
    describe "POST /create" do
      let(:headers) { { "CONTENT_TYPE" => "application/json", "Accept" => "application/json" } }
      let(:assessment) { parsed_response.fetch(:assessment).except(:id) }
      let(:employed) { false }
      let(:current_date) { Date.new(2022, 6, 6) }
      let(:default_params) do
        {
          assessment: { submission_date: current_date.to_s },
          applicant: { date_of_birth: "2001-02-02",
                       has_partner_opponent: false,
                       receives_qualifying_benefit: false,
                       employed: },
          proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
        }
      end
      let(:employment_income_params) do
        [
          {
            name: "Job 1",
            client_id: SecureRandom.uuid,
            payments: %w[2022-03-30 2022-04-30 2022-05-30].map do |date|
              {
                client_id: SecureRandom.uuid,
                gross: 446.00,
                net_employment_income: 398.84,
                benefits_in_kind: 16.60,
                tax: -104.10,
                national_insurance: -18.66,
                date:,
              }
            end,
          },
        ]
      end
      let(:vehicle_params) do
        [
          attributes_for(:vehicle, value: 2638.69, loan_amount_outstanding: 3907.77,
                                   date_of_purchase: "2022-03-05", in_regular_use: false),
          attributes_for(:vehicle, value: 4238.39, loan_amount_outstanding: 6139.36,
                                   date_of_purchase: "2021-09-23", in_regular_use: true),
        ]
      end
      let(:properties_params) do
        [
          {
            value: 1000,
            outstanding_mortgage: 0,
            percentage_owned: 99,
            shared_with_housing_assoc: false,
          },
          {
            value: 10_000,
            outstanding_mortgage: 40,
            percentage_owned: 80,
            shared_with_housing_assoc: true,
          },
        ]
      end
      let(:dependant_params) { attributes_for_list(:dependant, 2, relationship: "child_relative", monthly_income: 0) }
      let(:bank_1) { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
      let(:bank_2) { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
      let(:bank_account_params) do
        [
          {
            description: bank_1,
            value: 28.34,
          },
          {
            description: bank_2,
            value: 67.23,
          },
        ]
      end
      let(:asset_1) { "R.J.Ewing Trust" }
      let(:asset_2) { "Ming Vase" }
      let(:non_liquid_params) do
        [
          {
            description: asset_1,
            value: 17.12,
          },
          {
            description: asset_2,
            value: 6.19,
          },
        ]
      end

      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: file_fixture("bank-holidays.json").read)
        post v2_assessments_path, params: default_params.merge(params).to_json, headers:
      end

      context "with an assessment error" do
        let(:params) { { assessment: { submission_date: "3000-01-01" } } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response.except(:errors)).to eq({ success: false })
        end
      end

      context "with an invalid proceeding type" do
        let(:params) { { proceeding_types: [{ ccms_code: "ZZ", client_involvement_type: "A" }] } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response)
            .to eq({
              success: false,
              errors: ["The property '#/proceeding_types/0/ccms_code' value \"ZZ\" did not match one of the following values: DA001, DA002, DA003, DA004, DA005, DA006, DA007, DA020, SE003, SE004, SE013, SE014, SE007, SE008, SE015, SE016, SE095, SE097, SE003A, SE004A, SE007A, SE008A, SE013A, SE014A, SE015A, SE016A, SE095A, SE097A, SE101A, SE003E, SE004E, SE007E, SE008E, SE013E, SE014E, SE015E, SE016E, SE096E, SE099E, SE100E, SE101E in schema file://#"],
            })
        end
      end

      context "with no proceeding types" do
        let(:params) { { proceeding_types: [] } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response)
            .to eq({
              success: false,
              errors: ["The property '#/proceeding_types' did not contain a minimum number of items 1 in schema file://#"],
            })
        end
      end

      context "with an applicant error" do
        let(:params) do
          { applicant: { has_partner_opponent: false,
                         receives_qualifying_benefit: false,
                         employed: } }
        end

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response)
            .to eq({
              success: false,
              errors: ["The property '#/applicant' did not contain a required property of 'date_of_birth' in schema file://#"],
            })
        end
      end

      context "with an dependant error" do
        let(:params) { { dependants: {} } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response)
            .to eq({
              success: false,
              errors: ["The property '#/dependants' of type object did not match the following type: array in schema file://#"],
            })
        end
      end

      context "with dependents" do
        let(:params) { { dependants: dependant_params } }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "has dependant_allowance" do
          expect(parsed_response.dig(:result_summary, :disposable_income, :dependant_allowance)).to eq(615.28)
        end
      end

      context "with explicit remarks (needs to be contribution required to show in response)" do
        let(:params) do
          {
            capitals: { bank_accounts: attributes_for_list(:non_liquid_capital_item, 1, value: 20_000.0) },
            explicit_remarks: [
              {
                category: "policy_disregards",
                details: %w[employment charity],
              },
            ],
          }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "has remarks" do
          expect(parsed_response.dig(:assessment, :remarks)).to eq({ policy_disregards: %w[charity employment] })
        end
      end

      context "with invalid cash_transactions" do
        let(:params) { { cash_transactions: { income: {}, outgoings: [] } } }

        it "returns error" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error JSON" do
          expect(parsed_response)
            .to eq({
              success: false,
              errors: ["The property '#/income' of type object did not match the following type: array in schema file://public/schemas/cash_transactions.json"],
            })
        end
      end

      context "with cash transactions" do
        let(:month1) { current_date.beginning_of_month - 3.months }
        let(:month2) { current_date.beginning_of_month - 2.months }
        let(:month3) { current_date.beginning_of_month - 1.month }
        let(:params) do
          {
            cash_transactions:
              {
                income: [
                  {
                    category: "maintenance_in",
                    payments: cash_transactions(1033.44),
                  },
                  {
                    category: "friends_or_family",
                    payments: cash_transactions(250.0),
                  },
                ],
                outgoings: [
                  {
                    category: "maintenance_out",
                    payments: cash_transactions(256.0),
                  },
                  {
                    category: "child_care",
                    payments: cash_transactions(257.0),
                  },
                ],
              },
          }
        end

        it "has other_income" do
          expect(assessment.dig(:gross_income, :other_income, :monthly_equivalents))
            .to eq(
              {
                all_sources: { friends_or_family: 250.0, maintenance_in: 1033.44, property_or_lodger: 0.0, pension: 0.0 },
                bank_transactions: { friends_or_family: 0.0, maintenance_in: 0.0, property_or_lodger: 0.0, pension: 0.0 },
                cash_transactions: { friends_or_family: 250.0, maintenance_in: 1033.44, property_or_lodger: 0.0, pension: 0.0 },
              },
            )
        end

        def cash_transactions(amount)
          [month2, month3, month1].map do |p|
            {
              date: p.strftime("%F"),
              amount:,
              client_id: SecureRandom.uuid,
            }
          end
        end
      end

      context "with capitals" do
        let(:params) do
          {
            capitals: {
              bank_accounts: bank_account_params,
              non_liquid_capital: non_liquid_params,
            },
          }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        describe "capital items" do
          let(:capital_items) { assessment.fetch(:capital).fetch(:capital_items) }

          it "has liquid" do
            expect(capital_items.fetch(:liquid))
              .to eq(
                [{ description: bank_1, value: 28.34 }, { description: bank_2, value: 67.23 }],
              )
          end

          it "has non_liquid" do
            expect(capital_items.fetch(:non_liquid))
              .to eq(
                [{ description: "R.J.Ewing Trust", value: 17.12 }, { description: "Ming Vase", value: 6.19 }],
              )
          end
        end
      end

      context "with employment income" do
        let(:employed) { true }
        let(:params) { { employment_income: employment_income_params } }

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        describe "disposable_income from summary" do
          let(:employment_income) { parsed_response.dig(:result_summary, :disposable_income, :employment_income) }

          it "has employment income" do
            expect(employment_income)
              .to eq(
                {
                  gross_income: 446.0,
                  benefits_in_kind: 0.0,
                  tax: -104.1,
                  national_insurance: -18.66,
                  fixed_employment_deduction: -45.0,
                  net_employment_income: 278.24,
                },
              )
          end
        end

        describe "assessment" do
          describe "gross income" do
            let(:gross_income) { assessment.fetch(:gross_income) }

            it "has employment income" do
              expect(gross_income.fetch(:employment_income)).to eq(
                [
                  {
                    name: "Job 1",
                    payments: [
                      {
                        date: "2022-05-30",
                        gross: 446.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        net_employment_income: 339.84,
                      },
                      {
                        date: "2022-04-30",
                        gross: 446.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        net_employment_income: 339.84,
                      },
                      {
                        date: "2022-03-30",
                        gross: 446.0,
                        benefits_in_kind: 16.6,
                        tax: -104.1,
                        national_insurance: -18.66,
                        net_employment_income: 339.84,
                      },
                    ],
                  },
                ],
              )
            end
          end
        end
      end

      context "without dependants or cash transactions or employment income" do
        let(:payment_date) { 3.weeks.ago.strftime("%Y-%m-%d") }
        let(:outgoings_params) do
          [
            {
              name: "child_care",
              payments: [
                {
                  payment_date:,
                  amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
                  client_id: client_ids.first,
                },
                {
                  payment_date:,
                  amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
                  client_id: client_ids.last,
                },
              ],
            },
            {
              name: "maintenance_out",
              payments: %w[
                2022-10-15
                2022-11-15
                2022-12-15
              ].map { |v| { amount: 333.07, client_id: SecureRandom.uuid, payment_date: v } },
            },
            {
              name: "rent_or_mortgage",
              payments: [
                {
                  payment_date:,
                  amount: 351.49,
                  housing_cost_type: "rent",
                  client_id: "hc-r-1",
                },
                {
                  payment_date:,
                  amount: 351.49,
                  housing_cost_type: "rent",
                  client_id: "hc-r-2",
                },
              ],
            },
          ]
        end

        let(:other_income_params) do
          [
            {
              source: "maintenance_in",
              payments: [
                {
                  date: "2022-11-01",
                },
                {
                  date: "2022-10-01",
                },
                {
                  date: "2022-09-01",
                },
              ].map.with_index do |p, index|
                p.merge(
                  amount: 1046.44,
                  client_id: "oi-m-#{index}",
                )
              end,
            },
            {
              source: "friends_or_family",
              payments: [
                {
                  date: "2022-11-01",
                  amount: 250.00,
                  client_id: "ffi-m-3",
                },
                {
                  date: "2022-10-01",
                  amount: 266.02,
                  client_id: "ffi-m-2",
                },
                {
                  date: "2022-09-01",
                  amount: 250.00,
                  client_id: "ffi-m-1",
                },
              ],
            },
          ]
        end

        let(:irregular_income_payments) do
          [
            {
              income_type: "student_loan",
              frequency: "annual",
              amount: 456.78,
            },
          ]
        end
        let(:irregular_income_params) do
          {
            payments: irregular_income_payments,
          }
        end

        let(:client_ids) { [SecureRandom.uuid, SecureRandom.uuid, SecureRandom.uuid] }

        let!(:state_benefit_type1) { create :state_benefit_type, exclude_from_gross_income: true }
        let!(:state_benefit_type2) { create :state_benefit_type, exclude_from_gross_income: false }
        let(:state_benefit_params) do
          [
            {
              name: state_benefit_type1.label,
              payments: %w[2022-11-01 2022-10-01 2022-09-01].map.with_index do |date, index|
                {
                  date:, amount: 1033.44, client_id: "sb1-m#{index}"
                }
              end,
            },
            {
              name: state_benefit_type2.label,
              payments: %w[2022-11-01 2022-10-01 2022-09-01].map.with_index do |date, index|
                {
                  date:, amount: 266.02, client_id: "sb2-m#{index}"
                }
              end,
            },
          ]
        end

        let(:params) do
          {
            other_incomes: other_income_params,
            properties: {
              main_home: {
                value: 500_000,
                outstanding_mortgage: 200,
                percentage_owned: 15,
                shared_with_housing_assoc: true,
              },
              additional_properties: properties_params,
            },
            vehicles: vehicle_params,
            irregular_incomes: irregular_income_params,
            state_benefits: state_benefit_params,
            regular_transactions: [{ category: "maintenance_in",
                                     operation: "credit",
                                     amount: 9.99,
                                     frequency: "monthly" }],
            outgoings: outgoings_params,
            partner: {
              partner: { date_of_birth: "1987-08-08", employed: false },
              irregular_incomes: irregular_income_payments,
              employments: employment_income_params,
              regular_transactions: [{ category: "maintenance_in",
                                       operation: "credit",
                                       amount: 29.99,
                                       frequency: "monthly" }],
              state_benefits: state_benefit_params,
              additional_properties: properties_params,
              capitals: {
                bank_accounts: bank_account_params,
                non_liquid_capital: non_liquid_params,
              },
              dependants: dependant_params,
              vehicles: vehicle_params,
            },
          }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "contains JSON version and success" do
          expect(parsed_response.except(:timestamp, :result_summary, :assessment)).to eq({ version: "5", success: true })
        end

        describe "result summary" do
          let(:summary) { parsed_response.fetch(:result_summary) }

          it "has the correct keys" do
            expect(summary.keys).to match_array(%i[overall_result
                                                   gross_income
                                                   partner_gross_income
                                                   disposable_income
                                                   partner_disposable_income
                                                   capital
                                                   partner_capital])
          end

          it "has disposable income" do
            expect(summary.fetch(:disposable_income).except(:proceeding_types, :income_contribution,
                                                            :combined_total_outgoings_and_allowances,
                                                            :total_disposable_income, :combined_total_disposable_income,
                                                            :total_outgoings_and_allowances))
              .to eq(
                {
                  dependant_allowance: 0.0,
                  gross_housing_costs: 234.33,
                  housing_benefit: 0.0,
                  net_housing_costs: 234.33,
                  maintenance_allowance: 333.07,
                  employment_income: {
                    gross_income: 0.0,
                    benefits_in_kind: 0.0,
                    tax: 0.0,
                    national_insurance: 0.0,
                    fixed_employment_deduction: 0.0,
                    net_employment_income: 0.0,
                  },
                  partner_allowance: 191.41,
                },
              )
          end

          it "has partner disposable income" do
            expect(summary.fetch(:partner_disposable_income)).to eq(
              {
                dependant_allowance: 615.28,
                gross_housing_costs: 0.0,
                housing_benefit: 0.0,
                net_housing_costs: 0.0,
                maintenance_allowance: 0.0,
                total_outgoings_and_allowances: 974.45,
                total_disposable_income: -194.375,
                employment_income: {
                  gross_income: 446.0,
                  benefits_in_kind: 0.0,
                  tax: -104.1,
                  national_insurance: -18.66,
                  fixed_employment_deduction: -45.0,
                  net_employment_income: 278.24,
                },
                income_contribution: 0.0,
              },
            )
          end

          it "has capital" do
            expect(summary.fetch(:capital).except(:proceeding_types, :capital_contribution, :combined_capital_contribution,
                                                  :total_mortgage_allowance, :combined_assessed_capital))
              .to eq({
                total_liquid: 0.0,
                total_non_liquid: 0.0,
                total_vehicle: 2638.69,
                total_property: 8620.3,
                total_capital: 11_258.99,
                pensioner_capital_disregard: 0.0,
                subject_matter_of_dispute_disregard: 0.0,
                assessed_capital: 11_258.99,
              })
          end

          it "has partner capital" do
            expect(summary.fetch(:partner_capital).except(:assessed_capital, :total_mortgage_allowance))
              .to eq(
                {
                  total_liquid: 95.57,
                  total_non_liquid: 23.31,
                  total_vehicle: 2638.69,
                  total_property: 8620.3,
                  total_capital: 11_377.87,
                  pensioner_capital_disregard: 0.0,
                  subject_matter_of_dispute_disregard: 0.0,
                  capital_contribution: 0.0,
                },
              )
          end
        end

        describe "assessment" do
          it "has the correct keys" do
            expect(assessment.keys).to match_array(%i[client_reference_id submission_date applicant gross_income partner_gross_income disposable_income partner_disposable_income capital partner_capital remarks])
          end

          describe "remarks" do
            let(:remarks) { assessment.fetch(:remarks) }

            it "has other_income_payment" do
              expect(remarks.dig(:other_income_payment, :amount_variation))
                .to match_array(["ffi-m-3", "ffi-m-2", "ffi-m-1"])
            end

            it "has outgoings_housing_cost" do
              expect(remarks.fetch(:outgoings_housing_cost)).to eq(
                { unknown_frequency: ["hc-r-1", "hc-r-2"] },
              )
            end
          end

          it "has applicant" do
            expect(assessment.fetch(:applicant)).to eq(
              {
                date_of_birth: "2001-02-02",
                involvement_type: nil,
                employed: false,
                has_partner_opponent: false,
                receives_qualifying_benefit: false,
                self_employed: false,
              },
            )
          end

          describe "gross income" do
            let(:gross_income) { assessment.fetch(:gross_income) }

            it "has correct keys" do
              expect(gross_income.keys).to eq(%i[employment_income irregular_income state_benefits other_income])
            end

            it "has irregular income" do
              expect(gross_income.fetch(:irregular_income)).to eq(
                { monthly_equivalents: { student_loan: 38.065, unspecified_source: 0.0 } },
              )
            end

            describe "state benefits" do
              let(:monthly_equivalents) { gross_income.dig(:state_benefits, :monthly_equivalents) }

              it "has bank transactions" do
                expect(monthly_equivalents.fetch(:bank_transactions)).to match_array(
                  [
                    { name: state_benefit_type1.label, monthly_value: 1033.44, excluded_from_income_assessment: true },
                    { name: state_benefit_type2.label, monthly_value: 266.02, excluded_from_income_assessment: false },
                  ],
                )
              end
            end

            describe "other income" do
              let(:other_income) { gross_income.fetch(:other_income) }

              describe "monthly_equivalents" do
                let(:monthly_equivalents) { other_income.fetch(:monthly_equivalents) }

                it "has all_sources" do
                  expect(monthly_equivalents.fetch(:all_sources)).to eq(
                    {
                      friends_or_family: 255.34,
                      maintenance_in: 1056.43,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end

                it "has bank_transactions" do
                  expect(monthly_equivalents.fetch(:bank_transactions)).to eq(
                    {
                      friends_or_family: 255.34,
                      maintenance_in: 1046.44,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end

                it "has cash_transactions" do
                  expect(monthly_equivalents.fetch(:cash_transactions)).to eq(
                    {
                      friends_or_family: 0.0,
                      maintenance_in: 0.0,
                      property_or_lodger: 0.0,
                      pension: 0.0,
                    },
                  )
                end
              end
            end
          end

          describe "partner_gross_income" do
            let(:partner_gross_income) { assessment.fetch(:partner_gross_income) }

            it "has employment_income" do
              expect(partner_gross_income.fetch(:employment_income)).to eq(
                [{ name: "Job 1",
                   payments: [{ date: "2022-05-30",
                                gross: 446.0,
                                benefits_in_kind: 16.6,
                                tax: -104.1,
                                national_insurance: -18.66,
                                net_employment_income: 339.84 },
                              { date: "2022-04-30", gross: 446.0, benefits_in_kind: 16.6, tax: -104.1, national_insurance: -18.66, net_employment_income: 339.84 },
                              { date: "2022-03-30", gross: 446.0, benefits_in_kind: 16.6, tax: -104.1, national_insurance: -18.66, net_employment_income: 339.84 }] }],
              )
            end

            it "has irregular_income" do
              expect(partner_gross_income.dig(:irregular_income, :monthly_equivalents)).to eq(
                {
                  student_loan: 38.065,
                  unspecified_source: 0.0,
                },
              )
            end

            describe "state_benefits" do
              let(:state_benefits) { partner_gross_income.dig(:state_benefits, :monthly_equivalents) }

              it "has cash_transactions" do
                expect(state_benefits.excluding(:bank_transactions)).to eq(
                  {
                    all_sources: 266.02,
                    cash_transactions: 0.0,
                  },
                )
              end

              it "has bank_transactions" do
                expect(state_benefits.fetch(:bank_transactions).map { |g| g.except(:name) }).to eq(
                  [
                    { monthly_value: 1033.44, excluded_from_income_assessment: true },
                    { monthly_value: 266.02, excluded_from_income_assessment: false },
                  ],
                )
              end
            end

            it "has other_income" do
              expect(partner_gross_income.dig(:other_income, :monthly_equivalents)).to eq(
                {
                  all_sources: {
                    friends_or_family: 0.0,
                    maintenance_in: 29.99,
                    property_or_lodger: 0.0,
                    pension: 0.0,
                  },
                  bank_transactions: { friends_or_family: 0.0,
                                       maintenance_in: 0.0,
                                       property_or_lodger: 0.0,
                                       pension: 0.0 },
                  cash_transactions: {
                    friends_or_family: 0.0, maintenance_in: 0.0, property_or_lodger: 0.0, pension: 0.0
                  },
                },
              )
            end
          end

          it "has disposable income" do
            expect(assessment.fetch(:disposable_income)).to eq(
              { monthly_equivalents: { all_sources: { child_care: 0.0, rent_or_mortgage: 234.33, maintenance_out: 333.07, legal_aid: 0.0 },
                                       bank_transactions: { child_care: 0.0, rent_or_mortgage: 234.33, maintenance_out: 333.07, legal_aid: 0.0 },
                                       cash_transactions: { child_care: 0.0, rent_or_mortgage: 0.0, maintenance_out: 0.0, legal_aid: 0.0 } },
                childcare_allowance: 0.0,
                deductions: { dependants_allowance: 0.0, disregarded_state_benefits: 1033.44 } },
            )
          end

          it "has partner disposable income" do
            expect(assessment.fetch(:partner_disposable_income)).to eq(
              {
                monthly_equivalents: {
                  all_sources: {
                    child_care: 0.0,
                    rent_or_mortgage: 0.0,
                    maintenance_out: 0.0,
                    legal_aid: 0.0,
                  },
                  bank_transactions: {
                    child_care: 0.0,
                    rent_or_mortgage: 0.0,
                    maintenance_out: 0.0,
                    legal_aid: 0.0,
                  },
                  cash_transactions: {
                    child_care: 0.0,
                    rent_or_mortgage: 0.0,
                    maintenance_out: 0.0,
                    legal_aid: 0.0,
                  },
                },
                childcare_allowance: 0.0,
                deductions: { dependants_allowance: 615.28, disregarded_state_benefits: 1033.44 },
              },
            )
          end

          describe "capital items" do
            let(:capital_items) { assessment.fetch(:capital).fetch(:capital_items) }

            it "has vehicles" do
              expect(capital_items.fetch(:vehicles))
                .to eq(
                  [
                    {
                      value: 2638.69,
                      loan_amount_outstanding: 3907.77,
                      date_of_purchase: "2022-03-05",
                      in_regular_use: false,
                      included_in_assessment: true,
                      disregards_and_deductions: -3907.77,
                      assessed_value: 2638.69,
                    },
                    {
                      value: 4238.39,
                      loan_amount_outstanding: 6139.36,
                      date_of_purchase: "2021-09-23",
                      in_regular_use: true,
                      included_in_assessment: false,
                      disregards_and_deductions: -1900.9699999999993,
                      assessed_value: 0.0,
                    },
                  ],
                )
            end

            describe "has properties" do
              let(:properties) { capital_items.fetch(:properties) }

              it "has a main home" do
                expect(properties.fetch(:main_home))
                  .to eq({
                    value: 500_000.0,
                    outstanding_mortgage: 200.0,
                    percentage_owned: 15.0,
                    main_home: true,
                    shared_with_housing_assoc: true,
                    transaction_allowance: 15_000.0,
                    allowable_outstanding_mortgage: 200.0,
                    net_value: 484_800.0,
                    net_equity: 59_800.0,
                    main_home_equity_disregard: 100_000.0,
                    assessed_equity: 0.0,
                  })
              end

              it "has additional properties" do
                expect(properties.fetch(:additional_properties))
                  .to match_array(
                    [
                      {
                        value: 1000.0,
                        outstanding_mortgage: 0.0,
                        percentage_owned: 99.0,
                        main_home: false,
                        shared_with_housing_assoc: false,
                        transaction_allowance: 30.0,
                        allowable_outstanding_mortgage: 0.0,
                        net_value: 970.0,
                        net_equity: 960.3,
                        main_home_equity_disregard: 0.0,
                        assessed_equity: 960.3,
                      },
                      {
                        value: 10_000.0,
                        outstanding_mortgage: 40.0,
                        percentage_owned: 80.0,
                        main_home: false,
                        shared_with_housing_assoc: true,
                        transaction_allowance: 300.0,
                        allowable_outstanding_mortgage: 40.0,
                        net_value: 9660.0,
                        net_equity: 7660.0,
                        main_home_equity_disregard: 0.0,
                        assessed_equity: 7660.0,
                      },
                    ],
                  )
              end
            end
          end

          describe "partner_capital" do
            let(:partner_capital) { assessment.dig(:partner_capital, :capital_items) }

            it "has liquid" do
              expect(partner_capital.fetch(:liquid).map { |x| x.except(:description) })
                .to eq([{ value: 28.34 }, { value: 67.23 }])
            end

            it "has non_liquid" do
              expect(partner_capital.fetch(:non_liquid).map { |x| x.except(:description) })
                .to eq([{ value: 17.12 }, { value: 6.19 }])
            end

            it "has vehicles" do
              expect(partner_capital.fetch(:vehicles).map { |v| v.except(:date_of_purchase, :disregards_and_deductions) }).to eq(
                [
                  {
                    value: 2638.69,
                    loan_amount_outstanding: 3907.77,
                    in_regular_use: false,
                    included_in_assessment: true,
                    assessed_value: 2638.69,
                  },
                  {
                    value: 4238.39,
                    loan_amount_outstanding: 6139.36,
                    in_regular_use: true,
                    included_in_assessment: false,
                    assessed_value: 0.0,
                  },
                ],
              )
            end

            it "has properties" do
              expect(partner_capital.dig(:properties, :additional_properties))
                .to match_array(
                  [
                    {
                      value: 1000.0,
                      outstanding_mortgage: 0.0,
                      percentage_owned: 99.0,
                      main_home: false,
                      shared_with_housing_assoc: false,
                      transaction_allowance: 30.0,
                      allowable_outstanding_mortgage: 0.0,
                      net_value: 970.0,
                      net_equity: 960.3,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 960.3,
                    },
                    {
                      value: 10_000.0,
                      outstanding_mortgage: 40.0,
                      percentage_owned: 80.0,
                      main_home: false,
                      shared_with_housing_assoc: true,
                      transaction_allowance: 300.0,
                      allowable_outstanding_mortgage: 40.0,
                      net_value: 9660.0,
                      net_equity: 7660.0,
                      main_home_equity_disregard: 0.0,
                      assessed_equity: 7660.0,
                    },
                  ],
                )
            end
          end
        end
      end
    end
  end
end
