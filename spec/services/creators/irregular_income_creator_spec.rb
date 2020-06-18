require 'rails_helper'

module Creators
  RSpec.describe IrregularIncomeCreator do
    let(:gross_income_summary) { create :gross_income_summary }
    let(:assessment) { gross_income_summary.assessment }
    let(:frequency) { 'annual' }
    let(:student_loan) { 'student_loan' }
    let(:params) do
      {
        assessment_id: assessment.id,
        irregular_income: irregular_income_params
      }
    end
    subject { post assessment_irregular_income_path(assessment_id), params: params.to_json, headers: headers }
    subject { described_class.call(params) }

    describe '.call' do
      context 'payload' do
        it 'creates an irregular income payment' do
          expect { subject }.to change { IrregularIncomePayment.count }.by(1)
        end

        it 'creates a student loan payment' do
          subject
          payment = IrregularIncomePayment.find_by(gross_income_summary_id: gross_income_summary.id)
          expect(payment.frequency).to eq frequency
          expect(payment.income_type).to eq student_loan
          expect(payment.amount).to eq 123_456.78
        end
      end

      context 'empty payload' do
        let(:params) do
          {
            assessment_id: assessment.id,
            irregular_income: {
              payments: []
            }
          }
        end
        it 'does not create any records' do
          expect { subject }.not_to change { IrregularIncomePayment.count }
        end
      end

      context 'invalid assessment id' do
        let(:params) do
          {
            assessment_id: 'abcd',
            irregular_income: irregular_income_params
          }
        end
        it 'returns an error' do
          expect(subject.errors).to eq ['No such assessment id']
        end
      end
    end

    def irregular_income_params
      {
        payments: [
          {
            income_type: student_loan,
            frequency: frequency,
            amount: 123_456.78
          }
        ]
      }
    end
  end
end
