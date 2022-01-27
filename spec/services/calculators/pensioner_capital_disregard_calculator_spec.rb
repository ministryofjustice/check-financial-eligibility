require 'rails_helper'

module Calculators
  RSpec.describe PensionerCapitalDisregardCalculator do
    subject(:value) { described_class.new(assessment).value }
    let(:service) { described_class.new(assessment) }
    let(:assessment) { create :assessment, disposable_income_summary: disposable_income_summary, applicant: applicant }
    let(:capital_summary) { assessment.capital_summary }
    let(:disposable_income_summary) { create :disposable_income_summary, total_disposable_income: disposable_income }
    let(:disposable_income) { 0 }

    describe '#value' do
      context 'non-passported' do
        context 'not a pensioner' do
          let(:applicant) { create :applicant, :without_qualifying_benefits, :under_pensionable_age }

          it 'returns zero' do
            expect(service.value).to eq 0.0
          end
        end

        context 'a pensioner' do
          context 'non-passported' do
            let(:applicant) { create :applicant, :without_qualifying_benefits, :over_pensionable_age }

            context 'with an income of 0' do
              it 'returns the maximum value' do
                expect(service.value).to eq 100_000.0
              end
            end

            context 'with an income of 50.99' do
              let(:disposable_income) { 50.99 }

              it { is_expected.to eq 90_000.0 }
            end

            context 'with an income of 51' do
              let(:disposable_income) { 51.0 }

              it { is_expected.to eq 80_000.0 }
            end

            context 'with an income of 76.0' do
              let(:disposable_income) { 76.0 }

              it { is_expected.to eq 70_000.0 }
            end

            context 'with an income above the max threshold' do
              let(:disposable_income) { 316 }

              it { is_expected.to eq 0.0 }
            end
          end
        end
      end

      context 'passported' do
        let(:applicant) { create :applicant, :with_qualifying_benefits, :over_pensionable_age }

        it 'returns the passported value' do
          expect(service.value).to eq 100_000.0
        end
      end
    end
  end
end
