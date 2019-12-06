require 'rails_helper'

RSpec.describe EarnedIncomesCreationService do
  let(:assessment) { create :assessment }
  let(:assessment_id) { assessment.id }
  let(:gross_income_summary) { assessment.gross_income_summary }
  let(:employments) { [] }
  let(:expected_wages) { employments_hash.first[:wages] }
  let(:expected_benefits_in_kind) { employments_hash.first.dig(:benefits_in_kind, :monthly_taxable_values).first.to_a }

  subject do
    described_class.call(
      assessment_id: assessment_id,
      employments_attributes: employments
    )
  end

  describe '.call' do
    context 'with empty employments' do
      it 'returns an instance of EarnedIncomeObject' do
        expect(subject).to be_instance_of(described_class)
      end

      it 'does not create any earned income records' do
        expect(assessment.gross_income_summary.employments).to be_empty
      end
    end

    context 'with earned income' do
      let(:employments) { employments_hash }

      before { subject }

      it 'creates employment and wage_payment items' do
        # binding.pry
        expect(gross_income_summary.employments.size).to eq 1
        expect(gross_income_summary.employments.first.wage_payments.size).to eq 2
        expect(gross_income_summary.employments.first.benefit_in_kinds.size).to eq 2

        wages = gross_income_summary.employments.first.wage_payments.order(:created_at)
        expect(wages.first.date.strftime('%Y-%m-%d')).to eq expected_wages.first[:date]
        expect(wages.first.gross_payment).to eq expected_wages.first[:gross_payment]
        expect(wages.last.date.strftime('%Y-%m-%d')).to eq expected_wages.last[:date]
        expect(wages.last.gross_payment).to eq expected_wages.last[:gross_payment]

        benefits_in_kind = gross_income_summary.employments.first.benefit_in_kinds.order(:created_at)
        expect(benefits_in_kind.first.description).to eq expected_benefits_in_kind.first.first.to_s.humanize
        expect(benefits_in_kind.first.value).to eq expected_benefits_in_kind.first.last
        expect(benefits_in_kind.last.description).to eq expected_benefits_in_kind.last.first.to_s.humanize
        expect(benefits_in_kind.last.value).to eq expected_benefits_in_kind.last.last
      end
    end
  end

  describe '#success?' do
    it 'returns true' do
      expect(subject.success?).to be true
    end
  end

  describe '#gross_income_summary' do
    let(:employments) { employments_hash }

    it 'returns the created capital summary record' do
      result = subject.gross_income_summary
      expect(result).to be_instance_of(GrossIncomeSummary)
    end
  end

  def employments_hash
    [
      {
        "name": 'Employer name or reference',
        "wages": [
          {
            "date": '2019-11-01',
            "gross_payment": 1046.44
          },
          {
            "date": '2019-10-01',
            "gross_payment": 1034.33
          }
        ],
        "benefits_in_kind": {
          "monthly_taxable_values":
          [
            "company_car": 566.00,
            "health_insurance": 244.02
          ]
        }
      }
    ]
  end

  context 'no such assessment id' do
    let(:assessment_id) { SecureRandom.uuid }

    it 'does not create capital_items' do
      expect { subject }.not_to change { CapitalItem.count }
    end

    describe '#success?' do
      it 'returns false' do
        expect(subject.success?).to be false
      end
    end

    describe 'errors' do
      it 'returns an error' do
        expect(subject.errors.size).to eq 1
        expect(subject.errors[0]).to eq 'No such assessment id'
      end
    end
  end
end
