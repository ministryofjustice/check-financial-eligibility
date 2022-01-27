require 'rails_helper'

module Decorators
  RSpec.describe ErrorDecorator do
    describe '#as_json' do
      subject { described_class.new(param).as_json }

      context 'String' do
        let(:param) { 'This is an error' }
        it 'puts the string in the response struct' do
          expect(subject).to eq(errors: ['This is an error'], success: false)
        end
      end

      context 'CheckFinancialEligibilityError' do
        let(:param) { CheckFinancialEligibilityError.new('my message') }
        it 'puts the error message in the response struct' do
          expect(subject).to eq(errors: ['my message'], success: false)
        end
      end

      context 'Other exceptions' do
        let(:param) { generate_error }
        it 'generates a response struct with the correct keys' do
          expect(subject.keys).to eq(%i[errors success])
        end

        it 'generates message and backtrace in the errors array' do
          error_message = subject[:errors].first
          expect(error_message).to match(/My runtime error message/)
          expect(error_message).to match(/decorator_spec.rb:\d{2,4}:in `generate_error'/)
        end

        def generate_error
          raise 'My runtime error message'
        rescue RuntimeError => e
          e
        end
      end
    end
  end
end
