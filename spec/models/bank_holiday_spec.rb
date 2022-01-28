require 'rails_helper'

RSpec.describe BankHoliday, type: :model do
  let(:api_response) { %w[2015-01-01 2015-04-03 2015-04-06] }

  describe '.populate_dates' do
    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(api_response)
    end

    context 'no existing bank holidays record' do
      it 'creates a record' do
        expect(described_class.count).to be_zero
        described_class.populate_dates
        expect(described_class.count).to eq 1
      end

      it 'stores the api dates on the record' do
        described_class.populate_dates
        expect(described_class.first.dates).to eq api_response
      end
    end

    context 'pre-existing bank holidays record' do
      before do
        described_class.create!(dates: %w[2020-05-01 2020-04-03 2020-04-06])
      end

      it 'updates the existing record with the new api response' do
        described_class.populate_dates
        expect(described_class.first.dates).to eq api_response
      end

      it 'does not increase the record count' do
        described_class.populate_dates
        expect(described_class.count).to eq 1
      end
    end
  end

  describe '.dates' do
    context 'no record' do
      before do
        expect(described_class.count).to be_zero
        expect(described_class).to receive(:populate_dates)
        expect(described_class).to receive(:first).at_least(1).and_return(double(described_class, dates: api_response, updated_at: Time.zone.now))
      end

      it 'populates dates and returns dates' do
        expect(described_class.dates).to eq api_response
      end
    end

    context 'stale record' do
      before do
        described_class.create!(dates: api_response, updated_at: 11.days.ago)
        expect(described_class).to receive(:populate_dates)
        expect(described_class).to receive(:first).at_least(1).and_return(double(described_class, dates: api_response, updated_at: 11.days.ago))
      end

      it 'populates dates and returns dates' do
        expect(described_class.dates).to eq api_response
      end
    end

    context 'fresh record' do
      before do
        described_class.create!(dates: api_response, updated_at: 2.days.ago)
        expect(described_class).not_to receive(:populate_dates)
        expect(described_class).to receive(:first).at_least(1).and_return(double(described_class, dates: api_response, updated_at: 2.days.ago))
      end

      it 'populates dates and returns dates' do
        expect(described_class.dates).to eq api_response
      end
    end
  end
end
