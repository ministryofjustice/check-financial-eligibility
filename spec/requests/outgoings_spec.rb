require 'rails_helper'

RSpec.describe OutgoingsController, type: :request do
  describe 'POST /assessments/:assessment_id/outgoings' do
    let(:assessment) { create :assessment }
    let(:disposable_income_summary) { assessment.disposable_income_summary }
    let(:payment_date) { 3.weeks.ago.strftime('%Y-%m-%d') }
    let(:housing_cost_type) { Outgoings::HousingCost.housing_cost_types.values.sample }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:client_ids) { [SecureRandom.uuid, SecureRandom.uuid] }

    let(:params) do
      {
        outgoings: outgoings_params
      }
    end

    subject { post assessment_outgoings_path(assessment), params: params.to_json, headers: headers }

    it 'returns http success', :show_in_doc do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'creates outgoings' do
      expect { subject }.to change { Outgoings::BaseOutgoing.count }.by(6)
    end

    it 'sets success flag to true' do
      subject
      expect(parsed_response[:success]).to be true
    end

    it 'returns blank errors' do
      subject
      expect(parsed_response[:errors]).to be_empty
    end

    it 'stores the provided client id when given in params' do
      subject
      expect(Outgoings::Childcare.all.map(&:client_id)).to match_array(client_ids)
    end

    context 'with an invalid id' do
      let(:assessment) { 33 }

      before { subject }

      it 'returns unprocessable', :show_in_doc do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error information' do
        expect(parsed_response[:errors].join).to match(/Invalid.*assessment_id/)
      end

      it 'sets success flag to false' do
        expect(parsed_response[:success]).to be false
      end
    end

    context 'with an invalid payment date' do
      let(:payment_date) { 3.days.from_now.strftime('%Y-%m-%d') }

      before { subject }

      it 'returns unprocessable' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error information' do
        expect(parsed_response[:errors].join).to match(/Invalid.*payment_date/)
      end

      it 'sets success flag to false' do
        expect(parsed_response[:success]).to be false
      end
    end

    context 'missing required parameter client_id' do
      let(:params) do
        new_hash = outgoings_params
        new_hash.last[:payments].first.delete(:client_id)
        {
          outgoings: new_hash
        }
      end
      it 'returns unsuccessful' do
        subject
        expect(response.status).to eq 422
      end

      it 'contains success false in the response body' do
        subject
        expect(parsed_response).to eq(errors: ['Missing parameter client_id'], success: false)
      end

      it 'does not create outgoing records' do
        expect { subject }.not_to change { Outgoings::BaseOutgoing.count }
      end
    end

    context 'without housing costs or maintenance payments' do
      let(:params) do
        {
          outgoings: outgoings_params.select { |p| p[:name] == 'child_care' }
        }
      end

      it 'create the childcare records but does not create any other records' do
        expect { subject }.to change { Outgoings::BaseOutgoing.count }.by(2)
        expect(disposable_income_summary.childcare_outgoings.count).to eq 2
        expect(disposable_income_summary.housing_cost_outgoings.count).to eq 0
        expect(disposable_income_summary.maintenance_outgoings.count).to eq 0
      end
    end

    context 'with a failure to save' do
      let(:service) { double 'success?' => false, errors: [:foo] }
      before do
        expect(Creators::OutgoingsCreator).to receive(:call).and_return(service)
        subject
      end

      it 'returns unprocessable' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error information' do
        expect(parsed_response[:errors].join).to match(/foo/)
      end

      it 'sets success flag to false' do
        expect(parsed_response[:success]).to be false
      end
    end

    def outgoings_params
      [
        {
          name: 'child_care',
          payments: [
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              client_id: client_ids.first
            },
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              client_id: client_ids.last
            }
          ]
        },
        {
          name: 'maintenance_out',
          payments: [
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              client_id: client_ids.first
            },
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              client_id: client_ids.last
            }
          ]
        },
        {
          name: 'rent_or_mortgage',
          payments: [
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              housing_cost_type:,
              client_id: client_ids.first
            },
            {
              payment_date:,
              amount: Faker::Number.decimal(l_digits: 3, r_digits: 2),
              housing_cost_type:,
              client_id: client_ids.last
            }
          ]
        }
      ]
    end
  end
end
