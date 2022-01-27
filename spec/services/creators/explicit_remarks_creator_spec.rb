require 'rails_helper'

RSpec.describe Creators::ExplicitRemarksCreator do
  let(:assessment) { create :assessment }

  subject { described_class.call(assessment_id: assessment.id, remarks_attributes: params) }

  context 'valid payload' do
    let(:params) { valid_params }

    it 'creates the expected number of records' do
      expect { subject }.to change { ExplicitRemark.count }.by(2)
    end

    it 'is successful' do
      expect(subject.success?).to be true
    end

    it 'creates the right records' do
      subject
      expect(ExplicitRemark.where(assessment_id: assessment.id, category: 'policy_disregards').map(&:remark)).to match_array(%w[disregard_1 disregard_2])
    end
  end

  context 'invalid_params' do
    context 'unknown category' do
      let(:params) { invalid_params }

      it 'does not write any records' do
        expect { subject }.not_to change { ExplicitRemark.count }
      end

      it 'is not successful' do
        expect(subject.success?).to be false
      end

      it 'updates the error array' do
        expect(subject.errors).to eq ['Category other_stuff is not a valid remark category']
      end
    end
  end

  context 'unknown exception raised' do
    let(:params) { valid_params }

    it 'raises a Creation error' do
      allow_any_instance_of(described_class).to receive(:create_remark_category).and_raise(ArgumentError, 'Argument error detailed message')
      expect(subject.success?).to be false
      expect(subject.errors).to eq ['ArgumentError - Argument error detailed message']
    end
  end

  def valid_params
    [
      {
        category: 'policy_disregards',
        details: %w[disregard_1 disregard_2]
      }
    ]
  end

  def invalid_params
    [
      {
        category: 'policy_disregards',
        details: %w[xxxx zzzzz]
      },
      {
        category: 'other_stuff',
        details: %w[xxxx zzzzz]
      }
    ]
  end
end
