require 'rails_helper'

RSpec.describe DependentCreationService do
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

  context 'valid payload without income' do
    let(:request_payload) { valid_payload_without_income }

    it 'returns status code 200' do
      service.result_payload
      expect(service.http_status).to eq 200
    end

    it 'returns expected success payload' do
      expect(service.result_payload).to eq expected_result_payload
    end

    it 'creates two dependent records for this assessment' do
      expect {
        service.result_payload
      }.to change { Dependent.count }.by(2)

      dependent = assessment.dependents.order(:date_of_birth).first
      expect(dependent.date_of_birth).to eq 12.years.ago.to_date
      expect(dependent.in_full_time_education).to be false

      dependent = assessment.dependents.order(:date_of_birth).last
      expect(dependent.date_of_birth).to eq 6.years.ago.to_date
      expect(dependent.in_full_time_education).to be true
    end
  end

  context 'valid payload with income' do
    let(:request_payload) { valid_payload_with_income }

    it 'creates one dependent' do
      expect {
        service.result_payload
      }.to change { Dependent.count }.by(1)
    end

    it 'creates three income records' do
      expect {
        service.result_payload
      }.to change { DependentIncomeReceipt.count }.by(3)

      dirs = assessment.dependents.first.dependent_income_receipts.order(:date_of_payment)
      expect(dirs.first.date_of_payment).to eq 60.days.ago.to_date
      expect(dirs.first.amount).to eq 66.66

      expect(dirs[1].date_of_payment).to eq 40.days.ago.to_date
      expect(dirs[1].amount).to eq 44.44

      expect(dirs.last.date_of_payment).to eq 20.days.ago.to_date
      expect(dirs.last.amount).to eq 22.22
    end
  end

  context 'payload fails JSON schema' do
    let(:request_payload) { invalid_payload }

    it 'returns https status 422' do
      service.result_payload
      expect(service.http_status).to eq 422
    end

    it 'returns an error payload' do
      result = JSON.parse(service.result_payload, symbolize_names: true)
      expect(result[:status]).to eq 'error'
      expect(result[:errors].size).to eq 4
      expect(result[:errors][0]).to match %r{The property '#/' contains additional properties \[\"extra_property\"\] }
      expect(result[:errors][1]).to match %r{The property '#/dependents/0' did not contain a required property of 'in_full_time_education'}
      expect(result[:errors][2]).to match %r{The property '#/dependents/0' contains additional properties \[\"extra_dependent_property\"\]}
      expect(result[:errors][3]).to match %r{The property '#/dependents/1/income/0' contains additional properties \[\"reason\"\]}
    end

    it 'does not create a Dependent record' do
      expect {
        service.result_payload
      }.not_to change { Dependent.count }
    end

    it 'does not create any DependentIncomeReceipt records' do
      expect {
        service.result_payload
      }.not_to change { DependentIncomeReceipt.count }
    end
  end

  context 'payload fails ActiveRecord validations' do
    let(:request_payload) { payload_with_future_dates }

    it 'returns https status 422' do
      service.result_payload
      expect(service.http_status).to eq 422
    end

    it 'returns an error payload' do
      result = JSON.parse(service.result_payload, symbolize_names: true)
      expect(result[:status]).to eq 'error'
      expect(result[:errors].size).to eq 3
      expect(result[:errors][0]).to eq 'Dependent income receipts is invalid'
      expect(result[:errors][1]).to eq 'Date of birth cannot be in future'
      expect(result[:errors][2]).to eq 'Date of payment cannot be in the future'
    end

    it 'does not create a Dependent record' do
      expect {
        service.result_payload
      }.not_to change { Dependent.count }
    end

    it 'does not create any DependentIncomeReceipt records' do
      expect {
        service.result_payload
      }.not_to change { DependentIncomeReceipt.count }
    end
  end

  def invalid_payload
    {
      assessment_id: assessment.id,
      extra_property: 'this should not be here',
      dependents: [
        {
          extra_dependent_property: 'this should not be here',
          date_of_birth: 'not-a-valid-date'
        },
        {
          date_of_birth: '2016-02-03',
          in_full_time_education: true,
          income: [
            date_of_payment: 2.days.ago,
            amount: 44.00,
            reason: 'extra property'
          ]
        }
      ]
    }.to_json
  end

  def valid_payload_without_income
    {
      assessment_id: assessment.id,
      dependents: [
        {
          date_of_birth: 12.years.ago.to_date,
          in_full_time_education: false
        },
        {
          date_of_birth: 6.years.ago.to_date,
          in_full_time_education: true
        }
      ]
    }.to_json
  end

  def valid_payload_with_income
    {
      assessment_id: assessment.id,
      dependents: [
        {
          date_of_birth: 12.years.ago.to_date,
          in_full_time_education: false,
          income: [
            {
              date_of_payment: 60.days.ago.to_date,
              amount: 66.66
            },
            {
              date_of_payment: 40.days.ago.to_date,
              amount: 44.44
            },
            {
              date_of_payment: 20.days.ago.to_date,
              amount: 22.22
            }
          ]
        }

      ]
    }.to_json
  end

  def payload_with_future_dates
    {
      assessment_id: assessment.id,
      dependents: [
        {
          date_of_birth: 3.years.from_now,
          in_full_time_education: false,
          income: [
            {
              date_of_payment: Date.tomorrow,
              amount: 66.66
            },
            {
              date_of_payment: 40.days.ago.to_date,
              amount: 44.44
            },
            {
              date_of_payment: 20.days.ago.to_date,
              amount: 22.22
            }
          ]
        }

      ]
    }.to_json
  end

  def expected_result_payload
    {
      status: :ok,
      assessment_id: assessment.id,
      links: [
        {
          href: assessment_properties_path(assessment),
          rel: 'capital',
          type: 'POST'
        }
      ]
    }.to_json
  end

  def full_schema
    File.read(Rails.root.join('public/schemas/assessment_request.json'))
  end
end
