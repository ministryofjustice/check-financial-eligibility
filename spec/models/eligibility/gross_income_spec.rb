require 'rails_helper'

module Eligibility
  RSpec.describe GrossIncome do
    let(:gis) { create :gross_income_summary }
    let(:proceeding_type_code) { 'DA001' }
    let(:lower_threshold) { 3_000 }
    let(:upper_threshold) { 8_000 }
    let(:assessment_result) { 'pending' }
    let(:attrs) do
      {
        proceeding_type_code: proceeding_type_code,
        upper_threshold: upper_threshold,
        lower_threshold: lower_threshold,
        assessment_result: assessment_result
      }
    end

    context 'validation' do
      context 'everything valid' do
        it 'creates the expected record' do
          rec = gis.eligibilities.create(attrs)
          expect(rec).to be_valid
          expect(rec.parent_id).to eq gis.id
          expect(rec.type).to eq 'Eligibility::GrossIncome'
          expect(rec.proceeding_type_code).to eq 'DA001'
          expect(rec.lower_threshold).to eq 3_000
          expect(rec.upper_threshold).to eq 8_000
        end
      end

      context 'invalid proceeding type code' do
        let(:proceeding_type_code) { 'SE115' }
        it 'is not valid' do
          rec = gis.eligibilities.create(attrs)
          expect(rec).not_to be_valid
          expect(rec.errors[:proceeding_type_code]).to eq ['invalid: SE115']
        end
      end

      context 'adding duplicate record' do
        it 'raises not unique error' do
          gis.eligibilities.create(attrs)
          expect {
            gis.eligibilities.create(attrs)
          }.to raise_error ActiveRecord::RecordNotUnique, /PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint/
        end
      end
    end
  end
end
