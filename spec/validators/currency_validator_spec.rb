require 'rails_helper'

RSpec.describe CurrencyValidator do
  let(:params_description) { Faker::Commerce.product_name.underscore }
  let(:option) { nil }

  subject { described_class.new(params_description, option) }

  describe '#validate' do
    context 'no date option' do
      let(:option) { nil }

      context 'valid positive and negative numbers' do
        it 'returns true with a valid input' do
          [10, 10_000, 123.1, 123.12, -33.55].each do |number|
            expect(subject.validate(number)).to be true
          end
        end
      end

      context 'invalid input' do
        it 'returns false' do
          ['foo', 1.123444].each do |input|
            expect(subject.validate(input)).to be false
          end
        end
      end
    end

    context 'option :not_negative' do
      let(:option) { :not_negative }
      context 'value is negative' do
        it 'is invalid' do
          expect(subject.validate(-33.44)).to be false
        end
      end

      context 'value is zero' do
        it 'is valid' do
          expect(subject.validate(0.00)).to be true
        end
      end

      context 'value is positive' do
        it 'is valid' do
          expect(subject.validate(250.20)).to be true
        end
      end

      context 'invalid input' do
        it 'returns false' do
          ['foo', 1.123444].each do |input|
            expect(subject.validate(input)).to be false
          end
        end
      end
    end
  end

  describe 'description' do
    context 'no currency option' do
      let(:option) { nil }
      it 'returns a general message' do
        expect(subject.description).to eq 'Must be a decimal with a maximum of two decimal places. For example: 123.34'
      end
    end

    context 'currency option :not_negative' do
      let(:option) { :not_negative }
      it 'returns a general message' do
        expect(subject.description).to eq 'Must be a decimal, zero or greater, with a maximum of two decimal places. For example: 123.34'
      end
    end

  end



end
