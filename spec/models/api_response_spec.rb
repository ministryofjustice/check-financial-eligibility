require 'rails_helper'

RSpec.describe ApiResponse do
  let(:response) { ApiResponse.new }

  describe '.success' do
    let(:dummy_records) { %w[record_1 record_2] }

    subject { ApiResponse.success(dummy_records) }

    it 'sets success to true' do
      expect(subject.success?).to be true
    end

    it 'populates the objects array' do
      expect(subject.objects).to eq dummy_records
    end

    it 'sets errors to nil' do
      expect(subject.errors).to be_nil
    end
  end

  describe '.error' do
    let(:messages) { ['error 1', 'error 2'] }

    subject { ApiResponse.error(messages) }

    it 'sets success to true' do
      expect(subject.success?).to be false
    end

    it 'populates the objects array' do
      expect(subject.objects).to be_nil
    end

    it 'sets errors to nil' do
      expect(subject.errors).to eq messages
    end
  end
end
