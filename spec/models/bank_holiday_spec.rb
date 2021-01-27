require 'rails_helper'

RSpec.describe BankHoliday, type: :model do
  let(:api_response) { %w[2015-01-01 2015-04-03 2015-04-06] }

  describe '.populate_dates' do
    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(api_response)
    end

    context 'no existing bank holidays record' do
      it 'creates a record' do
        expect(BankHoliday.count).to be_zero
        BankHoliday.populate_dates
        expect(BankHoliday.count).to eq 1
      end

      it 'stores the api dates on the record' do
        BankHoliday.populate_dates
        expect(BankHoliday.first.dates).to eq api_response
      end
    end

    context 'pre-existing bank holidays record' do
      before do
        BankHoliday.create!(dates: %w[2020-05-01 2020-04-03 2020-04-06])
      end

      it 'updates the existing record with the new api response' do
        BankHoliday.populate_dates
        expect(BankHoliday.first.dates).to eq api_response
      end

      it 'does not increase the record count' do
        BankHoliday.populate_dates
        expect(BankHoliday.count).to eq 1
      end
    end
  end

  describe '.dates' do
    context 'no record' do
      before do
        expect(BankHoliday.count).to be_zero
        expect(BankHoliday).to receive(:populate_dates)
        expect(BankHoliday).to receive(:first).at_least(1).and_return(double(BankHoliday, dates: api_response, updated_at: Time.zone.now))
      end

      it 'populates dates and returns dates' do
        expect(BankHoliday.dates).to eq api_response
      end
    end
    context 'stale record' do
      before do
        BankHoliday.create!(dates: api_response, updated_at: 11.days.ago)
        expect(BankHoliday).to receive(:populate_dates)
        expect(BankHoliday).to receive(:first).at_least(1).and_return(double(BankHoliday, dates: api_response, updated_at: 11.days.ago))
      end

      it 'populates dates and returns dates' do
        expect(BankHoliday.dates).to eq api_response
      end
    end
    context 'fresh record' do
      before do
        BankHoliday.create!(dates: api_response, updated_at: 2.days.ago)
        expect(BankHoliday).not_to receive(:populate_dates)
        expect(BankHoliday).to receive(:first).at_least(1).and_return(double(BankHoliday, dates: api_response, updated_at: 2.days.ago))
      end

      it 'populates dates and returns dates' do
        expect(BankHoliday.dates).to eq api_response
      end
    end
  end
end
