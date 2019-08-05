require 'rails_helper'
require 'csv'

RSpec.describe IntegrationTests::WorksheetParser do
  let(:mock_worksheet_file) { Rails.root.join('spec', 'fixtures', 'integration_test_case.csv').freeze }
  let(:mock_worksheet_rows) { CSV.read(mock_worksheet_file).map { |rows| rows.map(&:to_s) } }
  let(:mock_worksheet) { double(GoogleDrive::Worksheet, rows: mock_worksheet_rows) }

  subject { described_class.call(mock_worksheet) }

  describe '#call' do
    it 'parses the test name and description' do
      expect(subject[:test_name]).to eq('Test number 1')
      expect(subject[:test_description]).to eq('Test of test')
    end

    it 'parses assesment' do
      expect(subject[:global][:submission_date]).to eq('29/5/2019')
      expect(subject[:global][:proceeding_type]).to eq('Non-Molestation Order')
    end

    it 'parses applicant' do
      expect(subject[:applicant][:dob]).to eq('29/3/1974')
      expect(subject[:applicant][:involvement_type]).to eq('Defendant')
    end

    it 'parses dependants' do
      expect(subject[:dependants].first[:dob]).to eq('2/2/2005')
      expect(subject[:dependants].second[:in_full_time_education]).to eq(true)
    end

    it 'parses applicant_capital property' do
      expect(subject[:applicant_capital][:property].first[:main_home]).to eq(true)
      expect(subject[:applicant_capital][:property].second[:value]).to eq('100000')
    end

    it 'parses applicant_capital bank_accts' do
      expect(subject[:applicant_capital][:liquid_capital_bank_accts].first[:lowest_balance]).to eq('5000')
      expect(subject[:applicant_capital][:liquid_capital_bank_accts].first[:lowest_balance_notes]).to eq('notes')
      expect(subject[:applicant_capital][:liquid_capital_bank_accts].second[:name]).to eq('bank acct 2')
    end

    it 'parses applicant_capital valuable_items' do
      expect(subject[:applicant_capital][:valuable_items].first[:value]).to eq('3000')
      expect(subject[:applicant_capital][:valuable_items].second[:description]).to eq('stamp collection')
    end

    it 'parses applicant_capital vehicles' do
      expect(subject[:applicant_capital][:vehicles].first[:value]).to eq('3000')
      expect(subject[:applicant_capital][:vehicles].second[:purchase_date]).to eq('2/2/2000')
    end

    it 'parses expected_results' do
      expect(subject[:expected_results][:gross_income_limit]).to eq('2657')
    end

    it 'parses expected_fixed_allowances' do
      expect(subject[:expected_fixed_allowances][:allowance_type][:employment_allowance]).to eq('45')
    end
  end
end
