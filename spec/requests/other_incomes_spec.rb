require 'rails_helper'

RSpec.describe OtherIncomesController, type: :request do
  describe 'POST other_income' do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { other_income_params  }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    subject { post assessment_other_incomes_path(assessment_id), params: params.to_json, headers: headers }

    context 'valid payload' do
      context 'with two sources' do
        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'creates two other income source records' do
          expect { subject }.to change { gross_income_summary.other_income_sources.count }.by(2)
          sources = gross_income_summary.other_income_sources.order(:name)
          expect(sources.first.name).to eq 'Help from family'
          expect(sources.last.name).to eq 'Student grant'
        end

        it 'creates the required number of OtherIncomePayment record for each source' do
          expect { subject }.to change { OtherIncomePayment.count }.by(6)
          source = gross_income_summary.other_income_sources.order(:name).first
          expect(source.other_income_payments.count).to eq 3
          payments = source.other_income_payments.order(:payment_date)

          expect(payments[0].payment_date).to eq Date.new(2019, 9, 1)
          expect(payments[0].amount).to eq 250.00

          expect(payments[1].payment_date).to eq Date.new(2019, 10, 1)
          expect(payments[1].amount).to eq 266.02

          expect(payments[2].payment_date).to eq Date.new(2019, 11, 1)
          expect(payments[2].amount).to eq 250.00
        end

        it 'returns a JSON representation of the other income records' do
          subject
          expect(parsed_response[:objects].size).to eq 2
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:success]).to eq true

          source = gross_income_summary.other_income_sources.find_by(name: 'Student grant')
          expect(parsed_response[:objects].first[:id]).to eq source.id
          expect(parsed_response[:objects].first[:gross_income_summary_id]).to eq gross_income_summary.id
          expect(parsed_response[:objects].first[:name]).to eq 'Student grant'

          source = gross_income_summary.other_income_sources.find_by(name: 'Help from family')
          expect(parsed_response[:objects].last[:id]).to eq source.id
          expect(parsed_response[:objects].last[:gross_income_summary_id]).to eq gross_income_summary.id
          expect(parsed_response[:objects].last[:name]).to eq 'Help from family'
        end
      end
    end

    context 'invalid_payload' do
      context 'missing source in the second element' do
        let(:params) do
          new_hash = other_income_params
          new_hash[:other_incomes].last.delete(:source)
          new_hash
        end

        it 'returns unsuccessful' do
          subject
          expect(response.status).to eq 422
        end

        it 'contains success false in the response body' do
          subject
          expect(parsed_response).to eq(errors: ['Missing parameter source'], success: false)
        end

        it 'does not create any other income source records' do
          expect { subject }.not_to change { OtherIncomeSource.count }
        end

        it 'does not create any other income payment records' do
          expect { subject }.not_to change { OtherIncomePayment.count }
        end
      end
    end

    context 'invalid_assessment_id' do
      let(:assessment_id) { SecureRandom.uuid }

      it 'returns unsuccessful' do
        subject
        expect(response.status).to eq 422
      end

      it 'contains success false in the response body' do
        subject
        expect(parsed_response).to eq(errors: ['No such assessment id'], success: false)
      end
    end

    def other_income_params
      {
        other_incomes: [
          {
            "source": 'Student grant',
            "payments": [
              {
                "date": '2019-11-01',
                "amount": 1046.44
              },
              {
                "date": '2019-10-01',
                "amount": 1034.33
              },
              {
                "date": '2019-09-01',
                "amount": 1033.44
              }
            ]
          },
          {
            "source": 'Help from family',
            "payments": [
              {
                "date": '2019-11-01',
                "amount": 250.00
              },
              {
                "date": '2019-10-01',
                "amount": 266.02
              },
              {
                "date": '2019-09-01',
                "amount": 250.00
              }
            ]
          }
        ]
      }
    end
  end
end
