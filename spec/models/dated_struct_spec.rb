require 'rails_helper'

RSpec.describe DatedStruct do
  subject { DatedStruct.new(dob: '1918-07-12', name: 'John', nationality: 'UK') }

  describe '.new' do
    it 'creates an OpensStruct-like structure' do
      expect(subject.name).to eq 'John'
      expect(subject.nationality).to eq 'UK'
    end

    it 'converts date strings into Date objects' do
      expect(subject.dob).to be_instance_of(Date)
      expect(subject.dob).to eq Date.new(1918, 7, 12)
    end
  end

  describe '#to_h' do
    it 'converts back to hash with symobolized keys' do
      expect(subject.to_h).to eq(dob: Date.new(1918, 7, 12), name: 'John', nationality: 'UK')
    end
  end

  describe '#to_json' do
    context 'without serialized as open struct option' do
      it 'converts back to json string' do
        expect(subject.to_json).to eq %({"dob":"1918-07-12","name":"John","nationality":"UK"})
      end
    end

    context 'with serialized as open struct option' do
      it 'converts back to json string with intermediate table key' do
        ds = DatedStruct.new({ dob: '1918-07-12', name: 'John', nationality: 'UK' }, serialize_as_open_struct: true)
        expect(ds.to_json(serialize_as_open_struct: true)).to eq %({"table":{"dob":"1918-07-12","name":"John","nationality":"UK"}})
      end
    end
  end
end
