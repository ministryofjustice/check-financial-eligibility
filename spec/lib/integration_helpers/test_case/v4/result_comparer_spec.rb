require Rails.root.join("lib/integration_helpers/test_case/v4/result_comparer")
require "rails_helper"

module TestCase
  module V4
    RSpec.describe ResultComparer do
      let(:verbosity) { 0 }
      let(:instance) { described_class.new(actual, expected, verbosity) }
      let(:actual) { actual_hash }
      let(:expected) { expected_hash }

      subject(:comparer) { instance.call }

      context "matter types" do
        context "mismatched matter type names" do
          let(:actual) { actual_modified_matter_type }

          it "outputs expected error messages" do
            expect(instance).to receive(:verbose).with("Matter type names do not match expected", :red)
            expect(instance).to receive(:verbose).with("  Actual  : domestic_abuse, housing", :red)
            expect(instance).to receive(:verbose).with("  Expected: domestic_abuse, section8", :red)
            expect(instance).to receive(:verbose).at_least(1)

            comparer
          end
        end

        context "matter type results do not match" do
          let(:actual) { modified_matter_type_result }

          it "outputs expected error messages" do
            expect(instance).to receive(:verbose).with("                               Matter type: domestic_abuse  eligible                   eligible", :green)
            expect(instance).to receive(:verbose).with("                                     Matter type: section8  ineligible                 eligible_with_contribution", :red)
            expect(instance).to receive(:verbose).at_least(1)
            comparer
          end
        end

        context "all well" do
          it "outputs nice green messages" do
            expect(instance).to receive(:verbose).with("                               Matter type: domestic_abuse  eligible                   eligible", :green)
            expect(instance).to receive(:verbose).with("                                     Matter type: section8  ineligible                 ineligible", :green)
            expect(instance).to receive(:verbose).at_least(1)
            comparer
          end
        end
      end

      context "proceeding_types" do
        context "mismatched proceeding type codes" do
          let(:actual) { actual_modified_proceeding_type_codes }

          it "outputs the expected error messages" do
            expect(instance).to receive(:verbose).with("Proceeding type codes do not match expected", :red)
            expect(instance).to receive(:verbose).with("  Expected: DA001, SE013", :red)
            expect(instance).to receive(:verbose).with("  Actual  : SE013, SE014", :red)
            expect(instance).to receive(:verbose).at_least(1)
            comparer
          end
        end
      end

      context "overall results" do
        let(:verbosity) { 0 }

        context "all well" do
          it "returns does not have any red text" do
            expect(instance).to receive(:verbose).with(instance_of(String), :green).at_least(1)
            expect(instance).not_to receive(:verbose).with(instance_of(String), :green)
            comparer
          end

          it "returns true" do
            expect(comparer).to be true
          end
        end

        context "results do not match" do
          let(:actual) { actual_modified_net_housing_costs }

          it "returns false" do
            expect(comparer).to be false
          end

          it "highlights the line in error in red" do
            expect(instance).to receive(:verbose).with("                                         net housing costs  1100.0                     1100.01", :red).and_call_original
            allow(instance).to receive(:verbose).with(instance_of(String), :green).at_least(1)
            allow(instance).to receive(:verbose).with(instance_of(String)).at_least(1)
            allow(instance).to receive(:verbose).with(instance_of(String), :blue).at_least(1)
            comparer
          end
        end
      end

      def expected_hash
        {
          assessment: {
            matter_types: [
              { domestic_abuse: "eligible" },
              { section8: "ineligible" }
            ],
            proceeding_types: {
              "DA001" => {
                result: "eligible",
                capital_lower_threshold: 3000.0,
                capital_upper_threshold: 999_999_999_999.0,
                gross_income_upper_threshold: 999_999_999_999.0,
                disposable_income_lower_threshold: 315.0,
                disposable_income_upper_threshold: 999_999_999_999.0,
              },
              "SE013" => {
                result: "ineligible",
                capital_lower_threshold: 3000.0,
                capital_upper_threshold: 8000.0,
                gross_income_upper_threshold: 2657.0,
                disposable_income_lower_threshold: 315.0,
                disposable_income_upper_threshold: 733.0,
              },
            },
            passported: false,
            assessment_result: "partially_eligible",
          },
          gross_income_summary: {
            monthly_other_income: 1244.0,
            monthly_state_benefits: 234.0,
            monthly_student_loan: 100.0,
            total_gross_income: 76_633.0,
          },
          disposable_income_summary: {
            childcare: 255.0,
            dependant_allowance: 300.0,
            maintenance: 400.0,
            gross_housing_costs: 50.0,
            housing_benefit: 600.0,
            net_housing_costs: 1100.0,
            total_outgoings_and_allowances: 1288.0,
            total_disposable_income: 4788.0,
            income_contribution: 0.0,

          },
          capital: {
            total_liquid: 0.0,
            total_non_liquid: 0.0,
            total_vehicle: 0.0,
            total_mortgage_allowance: 100_000.0,
            total_capital: 0.0,
            pensioner_capital_disregard: 0.0,
            assessed_capital: 0.0,
            capital_contribution: 0.0,
          },
          monthly_income_equivalents: {
            friends_or_family: 0.0,
            maintenance_in: 0.0,
            property_or_lodger: 0.0,
            student_loan: 0.0,
            pension: 0.0,
          },
          monthly_outgoing_equivalents: {
            maintenance_out: 0.0,
            child_care: 0.0,
            rent_or_mortgage: 0.0,
            legal_aid: 0.0,
          },
          deductions: {
            dependants_allowance: 0.0,
            disregarded_state_benefits: 0.0,
          },
        }
      end

      def actual_hash
        {
          version: "3",
          timestamp: "2021-03-24T18:52:37.514Z",
          success: true,
          result_summary: {
            overall_result: {
              result: "partially_eligible",
              capital_contribution: "3315.40",
              income_contribution: "245.55",
              matter_types: [
                {
                  matter_type: "domestic_abuse",
                  result: "eligible",
                },
                {
                  matter_type: "section8",
                  result: "ineligible",
                }
              ],
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  result: "eligible",
                },
                {
                  ccms_code: "SE013",
                  result: "ineligible",
                }
              ],
            },
            gross_income: {
              total_gross_income: "76633.0",
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  upper_threshold: "999999999999.0",
                  result: "eligible",
                },
                {
                  ccms_code: "SE013",
                  upper_threshold: "2657.0",
                  result: "eligble_with_contribution",
                }
              ],
            },
            disposable_income: {
              dependant_allowance: "1457.45",
              maintenance_allowance: "0.0",
              gross_housing_costs: "50.0",
              housing_benefit: "600.0",
              net_housing_costs: "1100.0",
              employment_income: {
                gross_income: 2717.0,
                benefits_in_kind: 0.0,
                tax: -798.64,
                national_insurance: -144.06,
                fixed_employment_deduction: -45.0,
                net_employment_income: 1774.3,
              },
              total_outgoings_and_allowances: "1288.0",
              income_contribution: "0.0",
              total_disposable_income: "4788.0",
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  lower_threshold: "315.0",
                  upper_threshold: "999999999999.0",
                  result: "eligible",
                },
                {
                  ccms_code: "SE013",
                  lower_threshold: "315.0",
                  upper_threshold: "733.0",
                  result: "eligble_with_contribution",
                }
              ],
            },
            capital: {
              total_liquid: "0.0",
              total_non_liquid: "0.0",
              total_vehicle: "0.0",
              total_property: "92500.0",
              total_mortgage_allowance: "100000.0",
              total_capital: "0.0",
              pensioner_capital_disregard: "0.0",
              capital_contribution: "0.0",
              assessed_capital: "0.0",
              proceeding_types: [
                {
                  ccms_code: "DA001",
                  lower_threshold: "3000.0",
                  upper_threshold: "999999999999.0",
                  result: "eligible",
                },
                {
                  ccms_code: "SE013",
                  lower_threshold: "3000.0",
                  upper_threshold: "8000.0",
                  result: "ineligible",
                }
              ],
            },
          },
          assessment: {
            id: "052c2dbc-947f-4d13-8b6f-9abc1a10cac2",
            client_reference_id: "NPE6-1",
            submission_date: "2019-05-29",
            assessment_result: "contribution_required",
            applicant: {
              date_of_birth: "1958-05-29",
              involvement_type: "applicant",
              has_partner_opponent: false,
              receives_qualifying_benefit: false,
              self_employed: false,
            },
            gross_income: {
              irregular_income: {
                monthly_equivalents: {
                  student_loan: "100.0",
                },
              },
              state_benefits: {
                monthly_equivalents: {
                  all_sources: "234.0",
                  cash_transactions: "0.0",
                  bank_transactions: [
                    {
                      name: "Child Benefit",
                      monthly_value: "200.0",
                      excluded_from_income_assessment: false,
                    }
                  ],
                },
              },
              other_income: {
                monthly_equivalents: {
                  all_sources: {
                    friends_or_family: "1244.0",
                    maintenance_in: "0.0",
                    property_or_lodger: "0.0",
                    pension: "0.0",
                  },
                },
              },
            },
            disposable_income: {
              monthly_equivalents: {
                bank_transactions: {
                  child_care: "0.0",
                  rent_or_mortgage: "50.0",
                  maintenance_out: "0.0",
                  legal_aid: "0.0",
                },
                cash_transactions: {
                  child_care: "255.0",
                  rent_or_mortgage: "0.0",
                  maintenance_out: "0.0",
                  legal_aid: "0.0",
                },
                all_sources: {
                  child_care: "255.0",
                  rent_or_mortgage: "50.0",
                  maintenance_out: "400.0",
                  legal_aid: "0.0",
                },
              },
              childcare_allowance: "0.0",
              deductions: {
                dependants_allowance: "300.0",
                disregarded_state_benefits: 0.0,
              },
            },
            capital: {
              capital_items: {
                liquid: [
                  { description: "Bank acct 1", value: "0.0" },
                  { description: "Bank acct 2", value: "0.0" },
                  { description: "Bank acct 3", value: "0.0" }
                ],
                non_liquid: [],
                vehicles: [
                  {
                    value: "9000.0",
                    loan_amount_outstanding: "0.0",
                    date_of_purchase: "2018-05-20",
                    in_regular_use: false,
                    included_in_assessment: true,
                    assessed_value: "9000.0",
                  }
                ],
                properties: {
                  main_home: {
                    value: "500000.0",
                    outstanding_mortgage: "150000.0",
                    percentage_owned: "50.0",
                    main_home: true,
                    shared_with_housing_assoc: false,
                    transaction_allowance: "15000.0",
                    allowable_outstanding_mortgage: "100000.0",
                    net_value: "385000.0",
                    net_equity: "192500.0",
                    main_home_equity_disregard: "100000.0",
                    assessed_equity: "92500.0",
                  },
                  additional_properties: [],
                },
              },

            },
            remarks: {
              state_benefit_payment: {
                amount_variation: %w[
                  e9260a99-db84-46ef-8c00-2682ac3bb9e1
                  9a6f8de4-f229-4816-9e67-5dcb04239a5f
                  424b9372-97d2-4bae-8c7c-91b803415ac1
                ],
                unknown_frequency: %w[
                  e9260a99-db84-46ef-8c00-2682ac3bb9e1
                  9a6f8de4-f229-4816-9e67-5dcb04239a5f
                  424b9372-97d2-4bae-8c7c-91b803415ac1
                ],
              },
            },
          },
        }
      end

      def actual_modified_matter_type
        new_actual = actual_hash.clone
        new_actual[:result_summary][:overall_result][:matter_types] = [
          {
            matter_type: "domestic_abuse",
            result: "eligible",
          },
          {
            matter_type: "housing",
            result: "eligible_with_contribution",
          }
        ]
        new_actual
      end

      def modified_matter_type_result
        new_actual = actual_hash.clone
        new_actual[:result_summary][:overall_result][:matter_types].last[:result] = "eligible_with_contribution"
        new_actual
      end

      def actual_modified_proceeding_type_codes
        new_actual = actual_hash.clone
        new_actual[:result_summary][:overall_result][:proceeding_types].first[:ccms_code] = "SE014"
        new_actual
      end

      def actual_modified_net_housing_costs
        new_actual = actual_hash.clone
        new_actual[:result_summary][:disposable_income][:net_housing_costs] = "1100.01"
        new_actual
      end
    end
  end
end
