require 'rails_helper'

module WorkflowService
  RSpec.describe LiquidCapitalAssessment do
    let(:service) { described_class.new(liquid_capital_request) }

    context 'all positive supplied' do
      let(:liquid_capital_request) { open_structify(all_positive_bank_accounts) }
      it 'adds them all together' do
        expect(service.call).to eq 136.87
      end
    end

    context 'mixture of positive and negative supplied' do
      let(:liquid_capital_request) { open_structify(mixture_of_negative_and_positive_bank_accounts) }
      it 'ignores negative values' do
        expect(service.call).to eq 35.88
      end
    end

    context 'all negative supplied' do
      let(:liquid_capital_request) { open_structify(all_negative_bank_accounts) }
      it 'ignores negative values' do
        expect(service.call).to eq 0.0
      end
    end

    def all_positive_bank_accounts
      {
        bank_accounts: [
          { account_name: 'Account 1', lowest_balance: 35.66 },
          { account_name: 'Account 2', lowest_balance: 100.99 },
          { account_name: 'Account 3', lowest_balance: 0.22 }
        ]
      }
    end

    def mixture_of_negative_and_positive_bank_accounts
      {
        bank_accounts: [
          { account_name: 'Account 1', lowest_balance: 35.66 },
          { account_name: 'Account 2', lowest_balance: -100.99 },
          { account_name: 'Account 3', lowest_balance: 0.22 }
        ]
      }
    end

    def all_negative_bank_accounts
      {
        bank_accounts: [
          { account_name: 'Account 1', lowest_balance: -35.66 },
          { account_name: 'Account 2', lowest_balance: - 100.99 },
          { account_name: 'Account 3', lowest_balance: -0.22 }
        ]
      }
    end
  end
end
