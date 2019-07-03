require 'rails_helper'

RSpec.describe OutgoingsCreationService do
  let(:assessment) { create :assessment }
  let(:outgoings) { attributes_for_list :outgoing, 2 }
  let(:payload) do
    { outgoings: outgoings, assessment_id: assessment.id }
  end

  subject { described_class.call(payload) }

  it 'creates two outgoings' do
    expect { subject.outgoings }.to change { assessment.outgoings.count }.by(2)
  end

  it 'succeeds' do
    expect(subject).to be_success
  end
end
