require 'rails_helper'

RSpec.describe OutgoingsController, type: :request do
  describe 'POST /assessments/:assessment_id/outgoings' do
    let(:assessment) { create :assessment }
    let(:payment_date) { 3.weeks.ago.strftime('%Y-%m-%d') }
    let(:outgoings) { attributes_for_list(:outgoing, 2, payment_date: payment_date) }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    let(:params) do
      {
        outgoings: outgoings
      }
    end

    subject { post assessment_outgoings_path(assessment), params: params.to_json, headers: headers }

    it 'returns http success', :show_in_doc do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'creates outgoings' do
      expect { subject }.to change { assessment.outgoings.count }.by(2)
    end

    it 'sets success flag to false' do
      subject
      expect(parsed_response[:success]).to be true
    end

    it 'returns blank errors' do
      subject
      expect(parsed_response[:errors]).to be_empty
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
  end
end
