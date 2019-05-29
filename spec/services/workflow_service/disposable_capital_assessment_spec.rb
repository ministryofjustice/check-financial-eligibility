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
  end
end
