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
  end
end
