require 'rails_helper'

module Creators
  RSpec.describe OtherIncomesCreator do
    let(:gross_income_summary) { create :gross_income_summary }
    let(:assessment) { gross_income_summary.assessment }
    let(:client_id) { [SecureRandom.uuid, SecureRandom.uuid].sample }
    let(:params) do
      {
        assessment_id: assessment.id,
        other_incomes: {
          other_incomes: other_income_params
        }
      }
    end

    subject { described_class.call(params) }

    describe '.call' do
      context 'payload with two sources' do
        let(:other_income_params) { standard_params }

        it 'creates two income source records' do
          expect { subject }.to change { OtherIncomeSource.count }.by(2)
        end

        it 'creates a student loan source with three payments' do
          subject
          source_record = OtherIncomeSource.find_by(gross_income_summary_id: gross_income_summary.id, name: 'student_loan')
          expect(source_record.other_income_payments.count).to eq 3
          expect(source_record.other_income_payments.map(&:amount)).to match_array([1046.44, 1034.33, 1033.44])
          expect(source_record.other_income_payments.map(&:payment_date)).to match_array(expected_dates)
        end
      end

      context 'payload with humanized form of source name' do
        let(:other_income_params) { humanized_params }

        it 'creates one income source record' do
          expect { subject }.to change { OtherIncomeSource.count }.by(1)
        end

        it 'creates a property_or_lodger with two payments' do
          subject
          source_record = OtherIncomeSource.find_by(gross_income_summary_id: gross_income_summary.id, name: 'property_or_lodger')
          expect(source_record.other_income_payments.count).to eq 2
          expect(source_record.other_income_payments.map(&:amount)).to match_array([1200.0, 1200.01])
          expect(source_record.other_income_payments.map(&:payment_date)).to match_array(humanized_expected_dates)
        end
      end
      context 'empty payload' do
        let(:other_income_params) { [] }
        it 'does not create any records' do
          expect { subject }.not_to change { OtherIncomeSource.count }
        end
      end

      context 'invalid assessment id' do
        let(:other_income_params) { humanized_params }
        let(:params) do
          {
            assessment_id: 'abcd',
            other_incomes: {
              other_incomes: other_income_params
            }
          }
        end
      end

      def expected_dates
        [
          Date.parse('2019-11-01'),
          Date.parse('2019-10-01'),
          Date.parse('2019-09-01')
        ]
      end

      def humanized_expected_dates
        [
          Date.parse('2019-11-12'),
          Date.parse('2019-10-09')
        ]
      end

      def standard_params
        [
          {
            source: 'student_loan',
            payments: [
              {
                date: '2019-11-01',
                amount: 1046.44,
                client_id: client_id
              },
              {
                date: '2019-10-01',
                amount: 1034.33,
                client_id: client_id
              },
              {
                date: '2019-09-01',
                amount: 1033.44,
                client_id: client_id
              }
            ]
          },
          {
            source: 'friends_or_family',
            payments: [
              {
                date: '2019-11-01',
                amount: 250.0,
                client_id: client_id
              },
              {
                date: '2019-10-01',
                amount: 266.02,
                client_id: client_id
              },
              {
                date: '2019-09-01',
                amount: 250.0,
                client_id: client_id
              }
            ]
          }
        ]
      end

      def humanized_params
        [
          {
            source: 'Property or lodger',
            payments: [
              {
                date: '2019-11-12',
                amount: 1200.0,
                client_id: client_id
              },
              {
                date: '2019-10-09',
                amount: 1200.01,
                client_id: client_id
              }
            ]
          }
        ]
      end
    end
  end
end
