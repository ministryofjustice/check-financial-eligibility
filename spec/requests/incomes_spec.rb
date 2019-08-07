require 'rails_helper'

RSpec.describe IncomesController, type: :request do
  describe 'POST /assessments/:assessment_id/incomes' do
    let(:assessment) { create :assessment }
    let(:benefit_receipts) { attributes_for_list(:benefit_receipt, 2) }
    let(:wage_slips) { attributes_for_list(:wage_slip, 2) }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:date_in_future) { 3.days.from_now.strftime('%Y-%m-%d') }

    let(:params) do
      {
        benefits: benefit_receipts,
        wage_slips: wage_slips
      }
    end

    subject { post assessment_income_path(assessment), params: params.to_json, headers: headers }

    it 'returns http success', :show_in_doc do
      subject
      expect(response).to have_http_status(:success)
    end

    it 'creates wage_slips' do
      expect { subject }.to change { assessment.wage_slips.count }.by(2)
    end

    it 'creates benefit_receipts' do
      expect { subject }.to change { assessment.benefit_receipts.count }.by(2)
    end

    it 'sets success flag to true' do
      subject
      expect(parsed_response[:success]).to be true
    end

    it 'returns blank errors' do
      subject
      expect(parsed_response[:errors]).to be_empty
    end

    it 'returns an array of wage_slips' do
      subject
      expect(parsed_response[:wage_slips].pluck(:id)).to include(WageSlip.order(:created_at).last.id)
      expect(parsed_response[:wage_slips].pluck(:paye)).to contain_exactly(*wage_slips.pluck(:paye).map(&:to_s))
    end

    it 'returns an array of benefit receipts' do
      subject
      expect(parsed_response[:benefits].pluck(:id)).to include(BenefitReceipt.order(:created_at).last.id)
      expect(parsed_response[:benefits].pluck(:amount)).to contain_exactly(*benefit_receipts.pluck(:amount).map(&:to_s))
    end

    shared_examples 'an unprocessable entity' do |invalid_item|
      before { subject }

      it 'returns unprocessable' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error information' do
        expect(parsed_response[:errors].join).to match(/Invalid.*#{invalid_item}/)
      end

      it 'sets success flag to false' do
        expect(parsed_response[:success]).to be false
      end
    end

    context 'with an invalid id' do
      let(:assessment) { 33 }

      it 'returns unprocessable', :show_in_doc do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it_behaves_like 'an unprocessable entity', 'assessment_id'
    end

    context 'with invalid input' do
      let(:wage_slips) { :invalid }

      it_behaves_like 'an unprocessable entity', 'wage_slips'
    end

    context 'with a future wage slip' do
      let(:wage_slips) { [attributes_for(:wage_slip, payment_date: date_in_future)] }

      it_behaves_like 'an unprocessable entity', 'payment_date'
    end

    context 'with a future benefit date' do
      let(:benefit_receipts) { [attributes_for(:benefit_receipt, payment_date: date_in_future)] }

      it_behaves_like 'an unprocessable entity', 'payment_date'
    end

    context 'with service returning error' do
      let(:error) { double 'success?' => false, errors: ['Invalid: foo'] }
      before { allow(IncomeCreationService).to receive(:call).and_return(error) }

      it_behaves_like 'an unprocessable entity', 'foo'
    end
  end
end
