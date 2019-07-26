require 'rails_helper'

module WorkflowService
  RSpec.describe LiquidCapitalAssessment do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment.id) }

    context 'all positive supplied' do
      it 'adds them all together' do
        assessment.bank_accounts << all_positive_bank_accounts
        expect(service.call).to eq 136.87
      end
    end

    context 'mixture of positive and negative supplied' do
      it 'ignores negative values' do
        assessment.bank_accounts << mixture_of_negative_and_positive_bank_accounts
        expect(service.call).to eq 35.88
      end
    end

    context 'all negative supplied' do
      it 'ignores negative values' do
        assessment.bank_accounts << all_negative_bank_accounts
        expect(service.call).to eq 0.0
      end
    end

    context 'no values supplied' do
      it 'returns 0' do
        expect(service.call).to eq 0.0
      end
    end

    def all_positive_bank_accounts
      [
        BankAccount.new(assessment_id: assessment.id, name: 'Account 1', lowest_balance: 35.66),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 2', lowest_balance: 100.99),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 3', lowest_balance: 0.22)
      ]
    end

    def mixture_of_negative_and_positive_bank_accounts
      [
        BankAccount.new(assessment_id: assessment.id, name: 'Account 1', lowest_balance: 35.66),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 2', lowest_balance: -100.99),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 3', lowest_balance: 0.22)
      ]
    end

    def all_negative_bank_accounts
      [
        BankAccount.new(assessment_id: assessment.id, name: 'Account 1', lowest_balance: -35.66),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 2', lowest_balance: -100.99),
        BankAccount.new(assessment_id: assessment.id, name: 'Account 3', lowest_balance: -0.22)
      ]
    end
  end
end
