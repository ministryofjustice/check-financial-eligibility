require 'rails_helper'

module WorkflowService
  RSpec.describe DisposableCapitalAssessment do
    let(:service) { DisposableCapitalAssessment.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }

    describe '#result_for' do
      it 'always returns true' do
        expect(service.result_for).to be true
      end

      context 'liquid capital' do
        context 'all positive supplied' do
          it 'adds them all together' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(all_positive_bank_accounts)
            expect(service.result_for).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 136.87
          end
        end

        context 'mixture of positive and negative supplied' do
          it 'ignores negative values' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(mixture_of_negative_and_positive_bank_accounts)
            expect(service.result_for).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 35.88
          end
        end

        context 'all negative supplied' do
          it 'ignores negative values' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(all_negative_bank_accounts)
            expect(service.result_for).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 0.0
          end
        end
      end

      context 'property' do
        context 'main_dwelling_only' do
          context '100% owned' do
            context 'with mortgage > £100,000' do
              it 'only deducts first 100k of mortgage' do
                particulars.request.applicant_capital.property = open_structify(main_dwelling_big_mortgage_wholly_owned)
                expect(service.result_for).to be true
                result = particulars.response.details.capital.property.main_dwelling
                expect(result.notional_sale_costs_pctg).to eq 3.0
                expect(result.net_value_after_deduction).to eq 452_983.21
                expect(result.maximum_mortgage_allowance).to eq 100_000.0
                expect(result.net_value_after_mortgage).to eq 352_983.21
                expect(result.percentage_owned).to eq 100.0
                expect(result.net_equity_value).to eq 352_983.21
                expect(result.property_disregard).to eq 100_000.0
                expect(result.assessed_capital_value).to eq 252_983.21
              end
            end

            context 'with_mortgage less than 100k' do
              it 'only deducts the actual outstanding amount' do
                particulars.request.applicant_capital.property = open_structify(main_dwelling_small_mortgage_wholly_owned)
                expect(service.result_for).to be true
                result = particulars.response.details.capital.property.main_dwelling
                expect(result.notional_sale_costs_pctg).to eq 3.0
                expect(result.net_value_after_deduction).to eq 452_983.21
                expect(result.maximum_mortgage_allowance).to eq 37_256.44
                expect(result.net_value_after_mortgage).to eq 415_726.77
                expect(result.percentage_owned).to eq 100.0
                expect(result.net_equity_value).to eq 415_726.77
                expect(result.property_disregard).to eq 100_000.0
                expect(result.assessed_capital_value).to eq 315_726.77
              end
            end
          end

          context '66.66% owned' do
            context 'with mortgage > £100,000' do
              it 'only deducts first 100k of mortgage' do
                particulars.request.applicant_capital.property = open_structify(main_dwelling_big_mortgage_partly_owned)
                expect(service.result_for).to be true
                result = particulars.response.details.capital.property.main_dwelling
                expect(result.notional_sale_costs_pctg).to eq 3.0
                expect(result.net_value_after_deduction).to eq 452_983.21
                expect(result.maximum_mortgage_allowance).to eq 100_000.0
                expect(result.net_value_after_mortgage).to eq 352_983.21
                expect(result.percentage_owned).to eq 66.66
                expect(result.net_equity_value).to eq 235_298.61
                expect(result.property_disregard).to eq 100_000.0
                expect(result.assessed_capital_value).to eq 135_298.61
              end
            end

            context 'with mortgage < £100,000' do
              it 'only deducts the actual outstanding amount' do
                particulars.request.applicant_capital.property = open_structify(main_dwelling_small_mortgage_partly_owned)
                expect(service.result_for).to be true
                result = particulars.response.details.capital.property.main_dwelling
                expect(result.notional_sale_costs_pctg).to eq 3.0
                expect(result.net_value_after_deduction).to eq 452_983.21
                expect(result.maximum_mortgage_allowance).to eq 37_256.44
                expect(result.net_value_after_mortgage).to eq 415_726.77
                expect(result.percentage_owned).to eq 66.66
                expect(result.net_equity_value).to eq 277_123.46
                expect(result.property_disregard).to eq 100_000.0
                expect(result.assessed_capital_value).to eq 177_123.46
              end
            end
          end
        end

        xcontext 'additional_properties and main dwelling' do
          context 'main dwelling wholly owned and additional properties wholly owned' do
            it 'deducts a maximum of £100k mortgage' do
              particulars.request.applicant_capital.property = open_structify(main_dwelling_and_addtional_properties_wholly_owned)
              expect(service.result_for).to be true
              ap1 = particulars.response.details.capital.property.additional_properties.first
              expect(ap1.notional_sale_costs_pctg).to eq 3.0
              expect(ap1.net_value_after_deduction).to eq 339_500.0
              expect(ap1.maximum_mortgage_allowance).to eq 55_000.0
              expect(ap1.net_value_after_mortgage).to eq 284_500.0
              expect(ap1.percentage_owned).to eq 100.0
              expect(ap1.net_equity_value).to eq 284_500.0
              expect(ap1.property_disregard).to eq 0.0
              expect(ap1.assessed_capital_value).to eq 284_500.0

              ap2 = particulars.response.details.capital.property.additional_properties[1]
              expect(ap2.notional_sale_costs_pctg).to eq 3.0
              expect(ap2.net_value_after_deduction).to eq 261_900.0
              expect(ap2.maximum_mortgage_allowance).to eq 40_000.0
              expect(ap2.net_value_after_mortgage).to eq 221_900.0
              expect(ap2.percentage_owned).to eq 100.0
              expect(ap2.net_equity_value).to eq 221_900.0
              expect(ap2.property_disregard).to eq 0.0
              expect(ap2.assessed_capital_value).to eq 221_900.0

              md = particulars.response.details.capital.property.main_dwelling
              expect(md.notional_sale_costs_pctg).to eq 3.0
              expect(md.net_value_after_deduction).to eq 213_400
              expect(md.maximum_mortgage_allowance).to eq 5_000.0
              expect(md.net_value_after_mortgage).to eq 208_400.0
              expect(md.percentage_owned).to eq 100.0
              expect(md.net_equity_value).to eq 208_400.0
              expect(md.property_disregard).to eq 100_000.0
              expect(md.assessed_capital_value).to eq 108_400.0
            end
          end
        end
      end
    end

    def open_structify(data)
      JSON.parse(data.to_json, object_class: OpenStruct)
    end

    def all_positive_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: 35.66 },
        { account_name: 'Account 2', lowest_balance: 100.99 },
        { account_name: 'Account 3', lowest_balance: 0.22 }
      ]
    end

    def mixture_of_negative_and_positive_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: 35.66 },
        { account_name: 'Account 2', lowest_balance: - 100.99 },
        { account_name: 'Account 3', lowest_balance: 0.22 }
      ]
    end

    def all_negative_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: -35.66 },
        { account_name: 'Account 2', lowest_balance: - 100.99 },
        { account_name: 'Account 3', lowest_balance: -0.22 }
      ]
    end

    def main_dwelling_big_mortgage_wholly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 266_000,
          percentage_owned: 100.0
        },
        other_properties: []
      }
    end

    def main_dwelling_small_mortgage_wholly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 37_256.44,
          percentage_owned: 100.0
        },
        other_properties: []
      }
    end

    def main_dwelling_big_mortgage_partly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 266_000,
          percentage_owned: 66.66
        },
        additional_properties: []
      }
    end

    def main_dwelling_small_mortgage_partly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 37_256.44,
          percentage_owned: 66.66
        },
        additional_properties: []
      }
    end

    def main_dwelling_and_addtional_properties_wholly_owned
      {
        main_home: {
          value: 220_000,
          outstanding_mortgage: 35_000,
          percentage_owned: 100.0
        },
        additional_properties: [
          {
            value: 350_000,
            outstanding_mortgage: 55_000,
            percentage_owned: 100
          },
          {
            value: 270_000,
            outstanding_mortgage: 40_000,
            percentage_owned: 100
          }
        ]
      }
    end
  end
end
