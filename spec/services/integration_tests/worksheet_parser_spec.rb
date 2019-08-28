require 'rails_helper'

RSpec.describe IntegrationTests::WorksheetParser do
  let(:spreadsheet_file) { Rails.root.join('spec/fixtures/integration_test_data.xlsx') }
  let(:spreadsheet) { Roo::Spreadsheet.open(spreadsheet_file.to_s) }
  let(:worksheet) { spreadsheet.sheet('Test Template') }

  subject { described_class.call(worksheet) }

  describe '#call' do
    it 'parses the test name and description' do
      expect(subject[:test_name]).to eq('Test template')
      expect(subject[:test_description]).to eq('Description of test')
    end

    it 'parses assesment' do
      pp subject[:assessment]
      expect(subject[:assessment][:submission_date].to_s).to eq('2019-05-29')
      expect(subject[:assessment][:matter_proceeding_type]).to eq('domestic_abuse')
    end

    it 'parses applicant' do
      expect(subject[:applicant][:date_of_birth].to_s).to eq('1974-03-29')
      expect(subject[:applicant][:involvement_type]).to eq('defendant')
    end

    it 'parses dependants' do
      expect(subject[:dependants].first[:date_of_birth].to_s).to eq('1990-02-02')
      expect(subject[:dependants].second[:in_full_time_education]).to eq(true)
    end

    it 'parses properties' do
      expect(subject[:properties][:main_home][:value]).to eq(100_000.0)
      expect(subject[:properties][:additional_properties].second[:value]).to eq(300_000.0)
    end

    it 'parses bank_accounts' do
      expect(subject[:capital][:bank_accounts].first[:value]).to eq(5000.0)
      expect(subject[:capital][:bank_accounts].second[:description]).to eq('bank acct 2')
    end

    it 'parses non liquid capital' do
      expect(subject[:capital][:non_liquid_capital].first[:value]).to eq(100.0)
      expect(subject[:capital][:non_liquid_capital].second[:description]).to eq('desc 2')
    end

    it 'parse vehicles' do
      expect(subject[:vehicles].first[:value]).to eq(16_000.0)
      expect(subject[:vehicles].second[:date_of_purchase].to_s).to eq('2018-12-07')
    end

    it 'parses expected_results' do
      expect(subject[:expected_results][:gross_income_limit]).to eq(2657.0)
    end

    it 'parses expected_fixed_allowances' do
      expect(subject[:expected_fixed_allowances][:allowance_type][:employment_allowance]).to eq(45.0)
    end
  end
end
