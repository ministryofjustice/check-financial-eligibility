require 'rails_helper'

describe Creators::CashTransactionsCreator do
  describe '.call' do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:income) { params[:income] }
    let(:outgoings) { params[:outgoings] }
    let(:month1) { Date.today.beginning_of_month - 3.months }
    let(:month2) { Date.today.beginning_of_month - 2.months }
    let(:month3) { Date.today.beginning_of_month - 1.months }

    subject { described_class.call(assessment_id: assessment.id, income: income, outgoings: outgoings) }

    context 'happy_path' do
      let(:params) { valid_params }
      it 'creates the cash transaction category records' do
        pp subject.errors
        expect{subject}.to change{CashTransactionCategory.count}.by(4)
      end
      it 'creates the payment records'
      it 'responds true to #success?'
    end

    context 'unhappy paths' do
      context 'not exactly three occurrences of payments' do
        it 'does not create any records'
        it 'returns expected errors'
        it 'responds false to #success?'
      end

      context 'not the expected dates' do
        it 'does not create any records'
        it 'returns expected errors'
        it 'responds false to #success?'
      end
    end

    def valid_params
      {
        income: [
          {
            category: "maintenance_in",
            payments: [
              {
                date: month1.strftime('%F'),
                amount: 1046.44,
                client_id: "05459c0f-a620-4743-9f0c-b3daa93e5711"
              },
              {
                date: month2.strftime('%F'),
                amount: 1034.33,
                client_id: "10318f7b-289a-4fa5-a986-fc6f499fecd0"
              },
              {
                date: month3.strftime('%F'),
                amount: 1033.44,
                client_id: "5cf62a12-c92b-4cc1-b8ca-eeb4efbcce21"
              }
            ]
          },
          {
            category: "friends_or_family",
            payments: [
              {
                date: month2.strftime('%F'),
                amount: 250.0,
                client_id: "e47b707b-d795-47c2-8b39-ccf022eae33b"
              },
              {
                date: month3.strftime('%F'),
                amount: 266.02,
                client_id: "b0c46cc7-8478-4658-a7f9-85ec85d420b1"
              },
              {
                date: month1.strftime('%F'),
                amount: 250.0,
                client_id: "f3ec68a3-8748-4ed5-971a-94d133e0efa0"
              }
            ]
          }
        ],
        outgoings:
          [
            {
              category: "maintenance_out",
              payments: [
                {
                  date: month2.strftime('%F'),
                  amount: 256.0,
                  client_id: "347b707b-d795-47c2-8b39-ccf022eae33b"
                },
                {
                  date: month3.strftime('%F'),
                  amount: 256.0,
                  client_id: "722b707b-d795-47c2-8b39-ccf022eae33b"
                },
                {
                  date: month1.strftime('%F'),
                  amount: 256.0,
                  client_id: "abcb707b-d795-47c2-8b39-ccf022eae33b"
                }
              ]
            },
            {
              category: "child_care",
              payments: [
                {
                  date: month3.strftime('%F'),
                  amount: 256.0,
                  client_id: "ff7b707b-d795-47c2-8b39-ccf022eae33b"
                },
                {
                  date: month2.strftime('%F'),
                  amount: 256.0,
                  client_id: "ee7b707b-d795-47c2-8b39-ccf022eae33b"
                },
                {
                  date: month1.strftime('%F'),
                  amount: 256.0,
                  client_id: "ec7b707b-d795-47c2-8b39-ccf022eae33b"
                }
              ]
            }
          ]
      }
    end
  end
end
