require 'rails_helper'

RSpec.describe IncomeCreationService do
  include Rails.application.routes.url_helpers
  let(:assessment) { create :assessment }
  let(:service) { described_class.new(request_payload) }

  before { stub_call_to_get_json_schema }

  shared_examples 'it did not create any records' do
    it 'does not create any WageSlip records' do
      expect {
        service.success?
      }.not_to change { WageSlip.count }
    end

    it 'does not create and BenefitReceipt records' do
      expect {
        service.success?
      }.not_to change { BenefitReceipt.count }
    end
  end

  context 'valid payload' do
    let(:request_payload) { valid_payload }

    describe '#success?' do
      it 'responds true' do
        expect(service.success?).to be true
      end
      it 'creates two WageSlip records' do
        expect {
          service.success?
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
          service.success?
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
  end

  context 'payload fails schema validation' do
    let(:request_payload) { invalid_payload }

    describe '#success?' do
      it 'is false' do
        expect(service.success?).to be false
      end
    end

    describe '#errors' do
      it 'stores all the errors' do
        service.success?
        expect(service.errors.size).to eq 4
        expect(service.errors[0]).to match %r{The property '#/' did not contain a required property of 'assessment_id'}
        expect(service.errors[1]).to match %r{The property '#/' contains additional properties \["extra_root_property"\]}
        expect(service.errors[2]).to match %r{The property '#/income' did not contain a required property of 'benefits'}
        expect(service.errors[3]).to match %r{The property '#/income' contains additional properties \["extra_income_property"\]}
      end
    end

    it_behaves_like 'it did not create any records'
  end

  context 'fails ActiveRecord validations' do
    let(:request_payload) { future_date_payload }

    describe '#success?' do
      it 'is false' do
        expect(service.success?).to be false
      end
    end

    describe '#errors' do
      it 'stores all the errors' do
        service.success?
        expect(service.errors.size).to eq 2
        expect(service.errors[0]).to eq 'Wage slip payment date cannot be in the future'
        expect(service.errors[1]).to eq 'Benefit payment date cannot be in the future'
      end
      it_behaves_like 'it did not create any records'
    end
  end

  context 'payload has invalid assessment id' do
    let(:request_payload) { payload_with_invalid_asssessment_id }

    describe '#success?' do
      it 'is false' do
        expect(service.success?).to be false
      end
    end

    describe '#errors' do
      it 'stores all the errors' do
        service.success?
        expect(service.errors.size).to eq 1
        expect(service.errors[0]).to eq 'No such assessment id'
      end

      it_behaves_like 'it did not create any records'
    end
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
end
