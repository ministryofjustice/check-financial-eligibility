require 'rails_helper'

module WorkflowService
  RSpec.describe PensionerCapitalDisregard do
    let(:service) { described_class.new(assessment) }
    let(:assessment) { create :assessment, applicant: applicant }
    let(:capital_summary) { assessment.capital_summary }

    describe '#value' do
      context 'passported' do
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
        end
      end
    end

    context 'unpassported' do
      let(:applicant) { create :applicant, :without_qualifying_benefits, :over_pensionable_age }
      it 'raises' do
        expect {
          service.value
        }.to raise_error 'Not implemented: PensionerCapitalDisregard for unpassported applicants'
      end
    end
  end
end
