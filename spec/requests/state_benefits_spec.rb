require 'rails_helper'

RSpec.describe StateBenefitsController, type: :request do
  describe 'POST state_benefit' do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { state_benefit_params }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    let!(:state_benefit_type_1) { create :state_benefit_type }
    let!(:state_benefit_type_2) { create :state_benefit_type }

    subject { post assessment_state_benefits_path(assessment_id), params: params.to_json, headers: headers }

    context 'valid payload' do
      context 'with two state benefits' do
        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'creates two state benefit records' do
          expect { subject }.to change { gross_income_summary.state_benefits.count }.by(2)
          state_benefit_types = gross_income_summary.state_benefits.map(&:state_benefit_type)
          expect(state_benefit_types).to match_array([state_benefit_type_1, state_benefit_type_2])
        end

        it 'creates state benefit payment records' do
          expect { subject }.to change { StateBenefitPayment.count }.by(6)
        end

        it 'creates payment records with correct values' do
          subject
          state_benefit = gross_income_summary.state_benefits.detect { |sb| sb.state_benefit_type == state_benefit_type_1 }
          payments = state_benefit.state_benefit_payments.order(:payment_date)
          expect(payments.first.payment_date).to eq Date.parse('2019-09-01')
        end
      end
    end

    context 'invalid_payload' do
      context 'missing source in the second element' do
        let(:params) do
          new_hash = state_benefit_params
          new_hash[:state_benefits].last.delete(:name)
          new_hash
        end

        it 'returns unsuccessful', :show_in_doc do
          subject
          expect(response.status).to eq 422
        end

        it 'contains success false in the response body' do
          subject
          expect(parsed_response).to eq(errors: ['Missing parameter name'], success: false)
        end

        it 'does not create any state benefit records' do
          expect { subject }.not_to change { StateBenefit.count }
        end

        it 'does not create any state benefit records' do
          expect { subject }.not_to change { StateBenefitPayment.count }
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

    def state_benefit_params
      {
        state_benefits: [
          {
            "name": state_benefit_type_1.label,
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
            "name": state_benefit_type_2.label,
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
