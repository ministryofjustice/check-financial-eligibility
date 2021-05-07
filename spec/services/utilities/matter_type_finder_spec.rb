require 'rails_helper'

module Utilities
  RSpec.describe MatterTypeFinder do
    describe '.call' do
      subject { described_class.call(code) }

      context 'successful lookup' do
        before { subject }

        context 'passed as a symbol' do
          let(:code) { :DA002 }
          it 'returns domestic abuse' do
            expect(subject).to eq 'domestic_abuse'
          end
        end

        context 'passsed as a string' do
          let(:code) { 'SE013' }
          it 'returns section8' do
            expect(subject).to eq 'section8'
          end
        end
      end

      context 'non-existing proceeding type' do
        let(:code) { 'XX024' }
        it 'raises' do
          expect { subject }.to raise_error KeyError, 'key not found: :XX024'
        end
      end
    end
  end
end
