require 'rails_helper'

RSpec.describe DependantsCreationService do
  include Rails.application.routes.url_helpers
  let(:assessment) { create :assessment }
  let(:assessment_id) { assessment.id }

  subject { described_class.call(assessment_id: assessment_id, dependants_attributes: dependants_attributes) }

  context 'valid payload without income' do
    let(:dependants_attributes) { valid_payload_without_income }

    it 'creates two dependant records for this assessment' do
      expect { subject }.to change { Dependant.count }.by(2)

      dependant = assessment.dependants.order(:date_of_birth).first
      expect(dependant.date_of_birth).to eq 12.years.ago.to_date
      expect(dependant.in_full_time_education).to be false

      dependant = assessment.dependants.order(:date_of_birth).last
      expect(dependant.date_of_birth).to eq 6.years.ago.to_date
      expect(dependant.in_full_time_education).to be true
    end

    describe '#success?' do
      it 'returns true' do
        expect(subject).to be_success
      end
    end

    describe '#dependants' do
      it 'returns the created dependants' do
        expect(subject.dependants.count).to eq(2)
        expect(subject.dependants.first).to be_a(Dependant)
        expect(subject.dependants.first.assessment.id).to eq(assessment.id)
      end
    end
  end

  context 'valid payload with income' do
    let(:dependants_attributes) { valid_payload_with_income }

    describe '#success?' do
      it 'creates one dependant' do
        expect { subject }.to change { Dependant.count }.by(1)
      end

      it 'creates three income records' do
        expect { subject }.to change { DependantIncomeReceipt.count }.by(3)

        dirs = assessment.dependants.first.dependant_income_receipts.order(:date_of_payment)
        expect(dirs.first.date_of_payment).to eq 60.days.ago.to_date
        expect(dirs.first.amount).to eq 66.66

        expect(dirs[1].date_of_payment).to eq 40.days.ago.to_date
        expect(dirs[1].amount).to eq 44.44

        expect(dirs.last.date_of_payment).to eq 20.days.ago.to_date
        expect(dirs.last.amount).to eq 22.22
      end
    end
  end

  context 'payload fails ActiveRecord validations' do
    let(:dependants_attributes) { payload_with_future_dates }

    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end

      it 'does not create a Dependant record' do
        expect { subject }.not_to change { Dependant.count }
      end

      it 'does not create any DependantIncomeReceipt records' do
        expect { subject }.not_to change { DependantIncomeReceipt.count }
      end
    end

    describe 'errors' do
      it 'returns an error payload' do
        expect(subject.errors.size).to eq 2
        expect(subject.errors).to include 'Dependant income receipts date of payment cannot be in the future'
        expect(subject.errors).to include 'Date of birth cannot be in future'
      end
    end
  end

  context 'no such assessment id' do
    let(:assessment_id) { 'hello' }
    let(:dependants_attributes) { valid_payload_without_income }

    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end

      it 'does not create a Dependant record' do
        expect { subject }.not_to change { Dependant.count }
      end

      it 'does not create any DependantIncomeReceipt records' do
        expect { subject }.not_to change { DependantIncomeReceipt.count }
      end
    end

    describe 'errors' do
      it 'returns an error payload' do
        expect(subject.errors.size).to eq 1
        expect(subject.errors[0]).to eq 'No such assessment id'
      end
    end
  end

  let(:valid_payload_without_income) do
    [
      {
        date_of_birth: 12.years.ago.to_date,
        in_full_time_education: false
      },
      {
        date_of_birth: 6.years.ago.to_date,
        in_full_time_education: true
      }
    ]
  end

  let(:valid_payload_with_income) do
    [
      {
        date_of_birth: 12.years.ago.to_date,
        in_full_time_education: false,
        income: [
          {
            date_of_payment: 60.days.ago.to_date,
            amount: 66.66
          },
          {
            date_of_payment: 40.days.ago.to_date,
            amount: 44.44
          },
          {
            date_of_payment: 20.days.ago.to_date,
            amount: 22.22
          }
        ]
      }

    ]
  end

  let(:payload_with_future_dates) do
    [
      {
        date_of_birth: 3.years.from_now.to_date,
        in_full_time_education: false,
        income: [
          {
            date_of_payment: Date.tomorrow,
            amount: 66.66
          },
          {
            date_of_payment: 40.days.ago.to_date,
            amount: 44.44
          },
          {
            date_of_payment: 20.days.ago.to_date,
            amount: 22.22
          }
        ]
      }
    ]
  end
end
