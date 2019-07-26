require 'rails_helper'
require 'csv'

RSpec.describe IntegrationTest do
  let(:worksheet_name) { 'foobar' }
  let(:mock_worksheet_file) { Rails.root.join('spec', 'fixtures', 'integration_test_case.csv').freeze }
  let(:mock_worksheet_rows) { CSV.read(mock_worksheet_file).map { |rows| rows.map(&:to_s) } }
  let(:mock_worksheet) { double(GoogleDrive::Worksheet, rows: mock_worksheet_rows) }
  let(:mock_spreadsheet) { double(GoogleDrive::Spreadsheet) }

  subject { described_class.call(worksheet_name) }

  before do
    allow(IntegrationTests::SpreadsheetRetriever).to receive(:call).and_return(mock_spreadsheet)
    allow(mock_spreadsheet).to receive(:worksheet_by_title).with(worksheet_name).and_return(mock_worksheet)
  end

  describe '#call', :vcr do
    # TODO: activate when controllers are fixed and CSV is aligned with new params
    xit 'runs the use case' do
      subject
    end

    context "with missing ENV['TEST_SPREADSHEET_ID']" do
      it 'fails' do
        with_modified_env TEST_SERVICE_URL: 'http://localhost:3000', TEST_SPREADSHEET_ID: '' do
          expect { subject }.to raise_error(/TEST_SPREADSHEET_ID/)
        end
      end
    end

    context "with missing ENV['TEST_SERVICE_URL']" do
      it 'fails' do
        with_modified_env TEST_SERVICE_URL: '' do
          expect { subject }.to raise_error(/TEST_SERVICE_URL/)
        end
      end
    end
  end
end
