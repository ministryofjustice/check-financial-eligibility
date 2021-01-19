require 'rails_helper'
require Rails.root.join('spec/fixtures/assessment_request_fixture.rb')

RSpec.describe Assessment, type: :model do
  let(:payload) { AssessmentRequestFixture.json }

  context 'missing ip address' do
    let(:param_hash) do
      {
        client_reference_id: 'client-ref-1',
        submission_date: Date.current,
        matter_proceeding_type: 'domestic_abuse'
      }
    end
    it 'errors' do
      assessment = Assessment.create param_hash
      expect(assessment.valid?).to be false
      expect(assessment.errors.full_messages).to include("Remote ip can't be blank")
    end
  end

  describe '#remarks' do
    context 'nil value in database' do
      it 'instantiates a new empty Remarks object' do
        assessment = create :assessment, remarks: nil
        expect(assessment.remarks.class).to eq Remarks
        expect(assessment.remarks.as_json).to eq Remarks.new(assessment.id).as_json
      end
    end

    context 'saving and reloading' do
      let(:remarks) do
        r = Remarks.new(assessment.id)
        r.add(:other_income_payment, :unknown_frequency, %w[abc def])
        r.add(:other_income_payment, :amount_variation, %w[ghu jkl])
        r
      end

      let(:assessment) { create :assessment }

      before { assessment.remarks = remarks }

      it 'reconstitutes into a remarks class with the same values' do
        expect(assessment.remarks.as_json).to eq remarks.as_json
      end
    end
  end
end
