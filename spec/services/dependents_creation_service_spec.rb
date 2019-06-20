require 'rails_helper'

RSpec.describe DependentsCreationService do
  include Rails.application.routes.url_helpers
  let(:assessment) { create :assessment }

  subject { described_class.call(request_payload) }

  before { stub_call_to_json_schema }

  context 'valid payload without income' do
    let(:request_payload) { valid_payload_without_income }

    it 'creates two dependent records for this assessment' do
      expect { subject }.to change { Dependent.count }.by(2)

      dependent = assessment.dependents.order(:date_of_birth).first
      expect(dependent.date_of_birth).to eq 12.years.ago.to_date
      expect(dependent.in_full_time_education).to be false

      dependent = assessment.dependents.order(:date_of_birth).last
      expect(dependent.date_of_birth).to eq 6.years.ago.to_date
      expect(dependent.in_full_time_education).to be true
    end

    describe '#success?' do
      it 'returns true' do
        expect(subject).to be_success
      end
    end

    describe '#dependents' do
      it 'returns the created dependents' do
        expect(subject.dependents.count).to eq(2)
        expect(subject.dependents.first).to be_a(Dependent)
        expect(subject.dependents.first.assessment.id).to eq(assessment.id)
      end
    end
  end

  context 'valid payload with income' do
    let(:request_payload) { valid_payload_with_income }
    describe '#success?' do
      it 'creates one dependent' do
        expect { subject }.to change { Dependent.count }.by(1)
      end

      it 'creates three income records' do
        expect { subject }.to change { DependentIncomeReceipt.count }.by(3)

        dirs = assessment.dependents.first.dependent_income_receipts.order(:date_of_payment)
        expect(dirs.first.date_of_payment).to eq 60.days.ago.to_date
        expect(dirs.first.amount).to eq 66.66

        expect(dirs[1].date_of_payment).to eq 40.days.ago.to_date
        expect(dirs[1].amount).to eq 44.44

        expect(dirs.last.date_of_payment).to eq 20.days.ago.to_date
        expect(dirs.last.amount).to eq 22.22
      end
    end
  end

  context 'payload fails JSON schema' do
    let(:request_payload) { invalid_payload }
    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end
    end

    it 'returns an error payload' do
      expect(subject.errors.size).to eq 6
      expect(subject.errors[0]).to match %r{The property '#/' contains additional properties \[\"extra_property\"\] }
      expect(subject.errors[1]).to match %r{The property '#/dependents/0' did not contain a required property of 'in_full_time_education'}
      expect(subject.errors[2]).to match %r{The property '#/dependents/0' contains additional properties \[\"extra_dependent_property\"\]}
      expect(subject.errors[3]).to match %r{The property '#/dependents/0/date_of_birth' value \"not-a-valid-date\" did not match the regex}
      expect(subject.errors[4]).to match %r{The property '#/dependents/1/income/0/date_of_payment' value \".+\" did not match the regex}
      expect(subject.errors[5]).to match %r{The property '#/dependents/1/income/0' contains additional properties \[\"reason\"\]}
    end

    it 'does not create a Dependent record' do
      expect { subject }.not_to change { Dependent.count }
    end

    it 'does not create any DependentIncomeReceipt records' do
      expect { subject }.not_to change { DependentIncomeReceipt.count }
    end
  end

  context 'payload fails ActiveRecord validations' do
    let(:request_payload) { payload_with_future_dates }
    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end

      it 'does not create a Dependent record' do
        expect { subject }.not_to change { Dependent.count }
      end

      it 'does not create any DependentIncomeReceipt records' do
        expect { subject }.not_to change { DependentIncomeReceipt.count }
      end
    end

    describe 'errors' do
      it 'returns an error payload' do
        expect(subject.errors.size).to eq 2
        expect(subject.errors).to include 'Dependent income receipts date of payment cannot be in the future'
        expect(subject.errors).to include 'Date of birth cannot be in future'
      end
    end
  end

  context 'no such assessment id' do
    let(:request_payload) { payload_with_invalid_id }
    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end

      it 'does not create a Dependent record' do
        expect { subject }.not_to change { Dependent.count }
      end

      it 'does not create any DependentIncomeReceipt records' do
        expect { subject }.not_to change { DependentIncomeReceipt.count }
      end
    end

    describe 'errors' do
      it 'returns an error payload' do
        expect(subject.errors.size).to eq 1
        expect(subject.errors[0]).to eq 'No such assessment id'
      end
    end
  end

  let(:payload_with_invalid_id) do
    {
      assessment_id: '34e353e2-dedb-4314-a271-9ff579e19f45',
      dependents: [
        {
          date_of_birth: 12.years.ago.to_date,
          in_full_time_education: false
        },
        {
          date_of_birth: 6.years.ago.to_date,
          in_full_time_education: true
        }
      ]
    }.to_json
  end

  let(:invalid_payload) do
    {
      assessment_id: assessment.id,
      extra_property: 'this should not be here',
      dependents: [
        {
          extra_dependent_property: 'this should not be here',
          date_of_birth: 'not-a-valid-date'
        },
        {
          date_of_birth: '2016-02-03',
          in_full_time_education: true,
          income: [
            date_of_payment: 2.days.ago,
            amount: 44.00,
            reason: 'extra property'
          ]
        }
      ]
    }.to_json
  end

  let(:valid_payload_without_income) do
    {
      assessment_id: assessment.id,
      dependents: [
        {
          date_of_birth: 12.years.ago.to_date,
          in_full_time_education: false
        },
        {
          date_of_birth: 6.years.ago.to_date,
          in_full_time_education: true
        }
      ]
    }.to_json
  end

  let(:valid_payload_with_income) do
    {
      assessment_id: assessment.id,
      dependents: [
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
    }.to_json
  end

  let(:payload_with_future_dates) do
    {
      assessment_id: assessment.id,
      dependents: [
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
    }.to_json
  end
end
