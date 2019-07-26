require 'rails_helper'

RSpec.describe IntegrationTests::SpreadsheetRetriever do
  let(:spreadsheet_key) { ENV['TEST_SPREADSHEET_ID'] }

  subject { described_class.call(spreadsheet_key) }

  describe '#call', :vcr do
    it 'returns a spreadsheet' do
      expect(subject).to be_a(GoogleDrive::Spreadsheet)
      expect(subject.id).to eq(spreadsheet_key)
    end

    context 'without env variables' do
      it 'fails' do
        with_modified_env GOOGLE_CLIENT_EMAIL: '' do
          expect { subject }.to raise_error(/GOOGLE_CLIENT_EMAIL/)
        end
      end

      it 'fails' do
        with_modified_env GOOGLE_PRIVATE_KEY: '' do
          expect { subject }.to raise_error(/GOOGLE_PRIVATE_KEY/)
        end
      end
    end
  end
end
