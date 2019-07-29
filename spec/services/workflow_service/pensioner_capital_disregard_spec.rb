require 'rails_helper'

module WorkflowService
  RSpec.describe PensionerCapitalDisregard do
    let(:service) { described_class.new(assessment) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, applicant: applicant }

    describe '#value' do
      context 'not a pensioner' do
        let(:applicant) { create :applicant, :under_pensionable_age }
        it 'returns zero' do
          expect(service.value).to eq 0.0
        end
      end

      context 'a pensioner' do
        context 'passported' do
          let(:applicant) { create :applicant, :with_qualifying_benfits, :over_pensionable_age }
          it 'returns the passported value' do
            expect(service.value).to eq 100_000.0
          end
        end

        context 'un-passported' do
          let(:applicant) { create :applicant, :over_pensionable_age }

          context 'monthly income above 315' do
            let!(:result) { create :result, assessment: assessment, disposable_monthly_income: 315.01 }
            it 'returns zero' do
              expect(service.value).to eq 0
            end
          end

          context 'monthly income 315' do
            let!(:result) { create :result, assessment: assessment, disposable_monthly_income: 315.0 }
            it 'returns 10_000' do
              expect(service.value).to eq 10_000
            end
          end

          context 'monthly_income 314.99' do
            let!(:result) { create :result, assessment: assessment, disposable_monthly_income: 314.99 }
            it 'returns 10_000' do
              expect(service.value).to eq 10_000
            end
          end

          context 'monthly_income 52' do
            let!(:result) { create :result, assessment: assessment, disposable_monthly_income: 52 }
            it 'returns 80_000' do
              expect(service.value).to eq 80_000
            end
          end

          context 'monthly_income 0' do
            let!(:result) { create :result, assessment: assessment, disposable_monthly_income: 0 }
            it 'returns 100_000' do
              expect(service.value).to eq 100_000
            end
          end

          context 'monthly income not set' do
            let!(:result) { create :result, assessment: assessment }
            it 'raises' do
              expect {
                service.value
              }.to raise_error RuntimeError, 'No disposable income specified for non-passported applicant'
            end
          end
        end
      end
    end
  end
end
