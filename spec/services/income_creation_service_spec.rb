require 'rails_helper'

RSpec.describe IncomeCreationService do
  include Rails.application.routes.url_helpers
  let(:assessment) { create :assessment }
  let(:service) { described_class.new(request_payload) }

  before do
    # stub request to get schema
    stub_request(:get, 'http://localhost:3000/schemas/assessment_request.json')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: full_schema, headers: {})
  end

  shared_examples 'an_error_response' do
    it 'returns status code 422' do
      service.result_payload
      expect(service.http_status).to eq 422
    end

    it 'does not create any WageSlip records' do
      expect {
        service.result_payload
      }.not_to change { WageSlip.count }
    end

    it 'does not create and BenefitReceipt records' do
      expect {
        service.result_payload
      }.not_to change { BenefitReceipt.count }
    end
  end

  context 'valid payload' do
    let(:request_payload) { valid_payload }
    it 'responds with expected success payload' do
      expect(service.result_payload).to eq expected_result_payload
    end

    it 'responds with status code 200' do
      service.result_payload
      expect(service.http_status).to eq 200
    end

    it 'creates two WageSlip records' do
      expect {
        service.result_payload
      }.to change { WageSlip.count }.by(2)

      slips = assessment.wage_slips.order(:payment_date)
      slip = slips.first
      expect(slip.payment_date).to eq 40.days.ago.to_date
      expect(slip.gross_pay).to eq 4_444.44
      expect(slip.paye).to eq 400.44
      expect(slip.nic).to eq 40.44

      slip = slips.last
      expect(slip.payment_date).to eq 10.days.ago.to_date
      expect(slip.gross_pay).to eq 1_111.11
      expect(slip.paye).to eq 100.11
      expect(slip.nic).to eq 10.11
    end

    it 'creates 2 BenefitReceipt records' do
      expect {
        service.result_payload
      }.to change { BenefitReceipt.count }.by(2)

      benefit_receipts = assessment.benefit_receipts.order(:payment_date)
      br = benefit_receipts.first
      expect(br.benefit_name).to eq 'child_allowance'
      expect(br.payment_date).to eq 15.days.ago.to_date
      expect(br.amount).to eq 200.66

      br = benefit_receipts.last
      expect(br.benefit_name).to eq 'jobseekers_allowance'
      expect(br.payment_date).to eq 2.days.ago.to_date
      expect(br.amount).to eq 100.44
    end
  end

  context 'payload fails schema validation' do
    let(:request_payload) { invalid_payload }

    it 'responds with error payload' do
      result = JSON.parse(service.result_payload, symbolize_names: true)
      expect(result[:status]).to eq 'error'
      expect(result[:assessment_id]).to be_nil
      expect(result[:errors].size).to eq 4
      expect(result[:errors][0]).to match %r{The property '#/' did not contain a required property of 'assessment_id'}
      expect(result[:errors][1]).to match %r{The property '#/' contains additional properties \["extra_root_property"\]}
      expect(result[:errors][2]).to match %r{The property '#/income' did not contain a required property of 'benefits'}
      expect(result[:errors][3]).to match %r{The property '#/income' contains additional properties \["extra_income_property"\]}
    end

    it_behaves_like 'an_error_response'
  end

  context 'fails ActiveRecord validations' do
    let(:request_payload) { future_date_payload }
    it 'responds with error payload' do
      result = JSON.parse(service.result_payload, symbolize_names: true)
      expect(result[:status]).to eq 'error'
      expect(result[:assessment_id]).to eq assessment.id
      expect(result[:errors].size).to eq 2
      expect(result[:errors][0]).to eq 'Wage slip payment date cannot be in the future'
      expect(result[:errors][1]).to eq 'Benefit payment date cannot be in the future'
    end

    it_behaves_like 'an_error_response'
  end

  context 'payload has invalid assessment id' do
    let(:request_payload) { payload_with_invalid_asssessment_id }

    it 'responds with error payload' do
      result = JSON.parse(service.result_payload, symbolize_names: true)
      expect(result[:status]).to eq 'error'
      expect(result[:assessment_id]).to eq 'b382e86e-3056-41bd-b39a-213c84ed6cac'
      expect(result[:errors].size).to eq 1
      expect(result[:errors].first).to eq 'No such assessment id'
    end

    it_behaves_like 'an_error_response'
  end

  def invalid_payload
    {
      extra_root_property: {
        this: :that
      },
      income: {
        extra_income_property: {
          this: :that
        },
        wage_slips: [
          {
            nic: 123.0,
            unknown: 44,
            extra_wage_slip_property: true
          }
        ]
      }
    }.to_json
  end

  def future_date_payload
    {
      assessment_id: assessment.id,
      income: {
        wage_slips: [
          {
            payment_date: Date.tomorrow,
            gross_pay: 4_444.44,
            paye: 400.44,
            nic: 40.44
          }
        ],
        benefits: [
          {
            benefit_name: 'child_allowance',
            payment_date: Date.tomorrow,
            amount: 200.66
          }
        ]
      }
    }.to_json
  end

  def valid_payload_as_hash
    {
      assessment_id: assessment.id,
      income: {
        wage_slips: [
          {
            payment_date: 40.days.ago.to_date,
            gross_pay: 4_444.44,
            paye: 400.44,
            nic: 40.44
          },
          {
            payment_date: 10.days.ago.to_date,
            gross_pay: 1_111.11,
            paye: 100.11,
            nic: 10.11
          }
        ],
        benefits: [
          {
            benefit_name: 'child_allowance',
            payment_date: 15.days.ago.to_date,
            amount: 200.66
          },
          {
            benefit_name: 'jobseekers_allowance',
            payment_date: 2.days.ago.to_date,
            amount: 100.44
          }
        ]
      }
    }
  end

  def valid_payload
    valid_payload_as_hash.to_json
  end

  def payload_with_invalid_asssessment_id
    valid_payload_as_hash.merge(assessment_id: 'b382e86e-3056-41bd-b39a-213c84ed6cac').to_json
  end

  def expected_result_payload
    {
      status: :ok,
      assessment_id: assessment.id,
      links: [
        {
          href: assessment_properties_path(assessment),
          rel: 'properties',
          type: 'POST'
        }
      ]
    }.to_json
  end

  def full_schema
    File.read(Rails.root.join('public/schemas/assessment_request.json'))
  end
end
