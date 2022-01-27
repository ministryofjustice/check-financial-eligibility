require 'rails_helper'

describe CashTransaction do
  let(:assessment1) { create :assessment, :with_gross_income_summary_and_records }
  let(:assessment2) { create :assessment, :with_gross_income_summary_and_records }
  let(:benefits_category1) { assessment1.cash_transaction_categories.detect { |cat| cat.name == 'benefits' } }
  let(:benefits_category2) { assessment2.cash_transaction_categories.detect { |cat| cat.name == 'benefits' } }
  let!(:benefits_transactions1) { benefits_category1.cash_transactions.order(:date) }
  let!(:benefits_transactions2) { benefits_category2.cash_transactions.order(:date) }

  describe 'by_operation_and_category' do
    it 'display all the cash transactions for benefits 1' do
      expect(described_class.by_operation_and_category(assessment1, :credit, :benefits)).to eq benefits_transactions1
    end

    it 'display all the cash transactions for benefits 2' do
      expect(described_class.by_operation_and_category(assessment2, :credit, :benefits)).to eq benefits_transactions2
    end
  end
end
