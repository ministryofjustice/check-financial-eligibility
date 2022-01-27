require 'rails_helper'

RSpec.describe CashTransactionsController, type: :request do
  describe 'POST cash_transactions' do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:creator_class) { Creators::CashTransactionsCreator }
    let(:month1) { Date.current.beginning_of_month - 3.months }
    let(:month2) { Date.current.beginning_of_month - 2.months }
    let(:month3) { Date.current.beginning_of_month - 1.month }

    subject { post assessment_cash_transactions_path(assessment_id), params: params.to_json, headers: headers }

    context 'valid payload' do
      let(:params) { valid_params }

      it 'returns http success', :show_in_doc do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'calls cash transactions creator' do
        expect(creator_class).to receive(:call).with(assessment_id:, income: params[:income], outgoings: params[:outgoings])
        subject
      end

      context 'creation is valid' do
        let(:creator_service) { double Creators::CashTransactionsCreator, success?: true }

        before do
          allow(creator_class).to receive(:call).and_return(creator_service)
          subject
        end

        it 'returns a success response body' do
          expect(parsed_response[:success]).to be true
          expect(parsed_response[:errors]).to be_empty
        end

        it 'returns successful http response' do
          expect(response.status).to eq 200
        end
      end

      context 'creation is invalid' do
        let(:creator_service) { double Creators::CashTransactionsCreator, success?: false, errors: ['error 1', 'error 2'] }

        before do
          allow(creator_class).to receive(:call).and_return(creator_service)
          subject
        end

        it 'returns a error response' do
          expect(parsed_response[:success]).to be false
          expect(parsed_response[:errors]).to eq ['error 1', 'error 2']
        end

        it 'returns unprocessable response' do
          expect(response.status).to eq 422
        end
      end
    end

    context 'invalid payload' do
      context 'invalid income category' do
        let(:params) { invalid_income_category_params }

        it 'returns an error' do
          subject
          expect(parsed_response[:success]).to eq false
          expect(parsed_response[:errors]).to eq [invalid_income_category_error_message]
        end

        it 'returns unprocessable' do
          subject
          expect(response.status).to eq 422
        end

        it 'does not call the CashTransactionCreator' do
          expect(creator_class).not_to receive(:call)
        end
      end

      context 'negative amounts' do
        let(:params) { invalid_negative_amount_params }

        it 'returns an error' do
          subject
          expect(parsed_response[:success]).to eq false
          expect(parsed_response[:errors]).to eq(
            ["Invalid parameter 'amount' value -100: Must be a decimal, zero or greater, with a maximum of two decimal places. For example: 123.34"]
          )
        end

        it 'returns unprocessable' do
          subject
          expect(response.status).to eq 422
        end

        it 'does not call the CashTransactionCreator' do
          expect(creator_class).not_to receive(:call)
        end
      end
    end

    # def parsed_response
    #   JSON.parse(response.body, symbolize_names: true)
    # end

    def valid_params
      {
        income: [
          {
            category: 'maintenance_in',
            payments: [
              {
                date: month1.strftime('%F'),
                amount: 1046.44,
                client_id: '05459c0f-a620-4743-9f0c-b3daa93e5711'
              },
              {
                date: month2.strftime('%F'),
                amount: 1034.33,
                client_id: '10318f7b-289a-4fa5-a986-fc6f499fecd0'
              },
              {
                date: month3.strftime('%F'),
                amount: 1033.44,
                client_id: '5cf62a12-c92b-4cc1-b8ca-eeb4efbcce21'
              }
            ]
          },
          {
            category: 'friends_or_family',
            payments: [
              {
                date: month2.strftime('%F'),
                amount: 250.0,
                client_id: 'e47b707b-d795-47c2-8b39-ccf022eae33b'
              },
              {
                date: month3.strftime('%F'),
                amount: 266.02,
                client_id: 'b0c46cc7-8478-4658-a7f9-85ec85d420b1'
              },
              {
                date: month1.strftime('%F'),
                amount: 250.0,
                client_id: 'f3ec68a3-8748-4ed5-971a-94d133e0efa0'
              }
            ]
          }
        ],
        outgoings:
          [
            {
              category: 'maintenance_out',
              payments: [
                {
                  date: month2.strftime('%F'),
                  amount: 256.0,
                  client_id: '347b707b-d795-47c2-8b39-ccf022eae33b'
                },
                {
                  date: month3.strftime('%F'),
                  amount: 256.0,
                  client_id: '722b707b-d795-47c2-8b39-ccf022eae33b'
                },
                {
                  date: month1.strftime('%F'),
                  amount: 256.0,
                  client_id: 'abcb707b-d795-47c2-8b39-ccf022eae33b'
                }
              ]
            },
            {
              category: 'child_care',
              payments: [
                {
                  date: month3.strftime('%F'),
                  amount: 258.0,
                  client_id: 'ff7b707b-d795-47c2-8b39-ccf022eae33b'
                },
                {
                  date: month2.strftime('%F'),
                  amount: 257.0,
                  client_id: 'ee7b707b-d795-47c2-8b39-ccf022eae33b'
                },
                {
                  date: month1.strftime('%F'),
                  amount: 256.0,
                  client_id: 'ec7b707b-d795-47c2-8b39-ccf022eae33b'
                }
              ]
            }
          ]
      }
    end

    def invalid_income_category_params
      params = valid_params.clone
      params[:income].first[:category] = 'xxxx'
      params
    end

    def invalid_negative_amount_params
      params = valid_params.clone
      params[:outgoings].last[:payments].last[:amount] = -100
      params
    end

    def invalid_income_category_error_message
      %(Invalid parameter 'category' value "xxxx": Must be one of: <code>benefits</code>, <code>friends_or_family</code>, <code>maintenance_in</code>, <code>property_or_lodger</code>, <code>pension</code>.)
    end
  end
end
