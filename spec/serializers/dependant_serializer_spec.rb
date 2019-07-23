require 'rails_helper'

RSpec.describe DependantSerializer do
  let(:dependant) { create :dependant }
  let(:serializer) { DependantSerializer.new(dependant) }

  it 'includes the expected attributes' do
    expect(serializer.attributes.keys).to contain_exactly(:date_of_birth, :in_full_time_education)
  end

  it 'does not contain invalid JSON attributes' do
    expect(serializer.attributes.keys).not_to include('dummy')
  end

  it 'should have attributes that match the dependant' do
    expect(serializer.serializable_hash[:date_of_birth]).to eq(dependant.date_of_birth)
    expect(serializer.serializable_hash[:in_full_time_education]).to eq(dependant.in_full_time_education)
  end
end
