require 'rails_helper'

module WorkflowService
  RSpec.describe PensionerCapitalDisregard do
    let(:service) { described_class.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }

    describe '#value' do
      context 'not a pensioner' do
        before do
          particulars.request.applicant.date_of_birth = 59.years.ago.to_date
        end
        it 'returns zero' do
         expect(service.value).to eq 0.0
        end
      end

      context 'a pensioner' do
        context 'passported' do
          before do
            particulars.request.applicant.receives_qualifying_benefit = true
          end
          it 'returns the passported value' do
            expect(service.value).to eq 100_000.0
          end
        end

        context 'un-passported' do
          before do
            particulars.request.applicant.receives_qualifying_benefit = false
          end

          context 'monthly income above 315' do
            before do
              particulars.response.details.income.monthly_disposable_income = 315.01
            end
            it 'returns zero' do
              expect(service.value).to eq 0
            end
          end

          context 'monthly income 315' do
            before do
              particulars.response.details.income.monthly_disposable_income = 315.0
            end
            it 'returns 10_000' do
              expect(service.value).to eq 10_000
            end
          end

          context 'monthly_income 314.99' do
            before do
              particulars.response.details.income.monthly_disposable_income = 314.99
            end
            it 'returns 20_000' do
              expect(service.value).to eq 10_000
            end
          end

          context 'monthly_income 52' do
            before do
              particulars.response.details.income.monthly_disposable_income = 52
            end
            it 'returns 80_000' do
              expect(service.value).to eq 80_000
            end
          end

          context 'monthly_income 0' do
            it 'returns 100_000' do
              expect(service.value).to eq 100_000
            end
          end

          context 'monthly income not set' do
            before do
              particulars.response.details.income.delete_field(:monthly_disposable_income)
            end
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
