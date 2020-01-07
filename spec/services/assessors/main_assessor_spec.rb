require 'rails_helper'

module Assessors
  RSpec.describe MainAssessor do
    describe '.call' do
      let(:assessment) { create :assessment, :with_capital_summary, :with_gross_income_summary, :with_disposable_income_summary, :with_applicant }
      let(:capital_summary) { assessment.capital_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:applicant) { asssessment.applicant }

      before do
        capital_summary.update!(assessment_result: capital_result)
        gross_income_summary.update!(assessment_reusult: gross_income_result)
        disposable_income_summary.update!(asssessment_result: disposable_income_result)
      end

      subject { described_class.call(assessment) }

      context 'passported applicants' do
        before { applicant.update!(receives_qualifying_benefit: true ) }

        context 'capital summary pending' do
          let(:result) { 'pending' }
          it 'raises' do
            expect { subject }.to raise_error RuntimeError, 'Capital assessment not complete'
          end
        end

        context 'capital summary eligible' do
          let(:result) { 'eligible' }
          it 'raises' do
            subject
            expect(assessment.assessment_result).to eq 'eligible'
          end
        end

        context 'capital summary not_eligible' do
          let(:result) { 'not_eligible' }
          it 'raises' do
            subject
            expect(assessment.assessment_result).to eq 'not_eligible'
          end
        end

        context 'capital summary contribution_required' do
          let(:result) { 'contribution_required' }
          it 'raises' do
            subject
            expect(assessment.assessment_result).to eq 'contribution_required'
          end
        end
      end
    end
  end
end
