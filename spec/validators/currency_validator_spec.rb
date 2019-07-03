require 'rails_helper'

RSpec.describe CurrencyValidator do
  let(:params_description) { Faker::Commerce.product_name.underscore }

  subject { described_class.new(params_description) }

  describe '#validate' do
    it 'returns true with a valid input' do
      [10, 10_000, 123.1, 123.12].each do |number|
        expect(subject.validate(number)).to be_truthy
      end
    end

    it 'returns false with invalid input' do
      ['foo', 1.123444].each do |input|
        expect(subject.validate(input)).to be_falsey
      end
    end
  end

  describe 'description' do
    it 'returns a string' do
      expect(subject.description).to be_a(String)
    end
  end
end
