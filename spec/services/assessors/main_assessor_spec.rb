require 'rails_helper'

module Assessors
  RSpec.describe MainAssessor do
    describe '.call' do
      let(:assessment) { create :assessment, :with_capital_summary, :with_gross_income_summary, :with_disposable_income_summary, :with_applicant }
      let(:capital_summary) { assessment.capital_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:applicant) { assessment.applicant }

      before do
        capital_summary.update!(assessment_result: capital_result)
        gross_income_summary.update!(assessment_result: gross_income_result)
        disposable_income_summary.update!(assessment_result: disposable_income_result)
      end

      subject { described_class.call(assessment) }

      context 'passported' do
        before { applicant.update!(receives_qualifying_benefit: true) }
        context 'gross income pending' do
          let(:gross_income_result) {'pending'}
          context 'disposable income pending' do
            let(:disposable_income_result) {'pending'}
            context 'capital pending' do
              let(:capital_result) {'pending'}
              it 'should raise' do
                expect{subject}.to raise_error RuntimeError, 'Assessment not complete: Capital assessment still pending'
              end
            end

            context 'capital eligible' do
              let(:capital_result) {'eligible'}
              it 'should set the assessment to eligible' do
                subject
                expect(assessment.assessment_result).to eq 'eligible'
              end
            end

            context 'capital contribution_required' do
              let(:capital_result) {'contribution_required'}
              it 'should set the assessment to contribution required' do
                subject
                expect(assessment.assessment_result).to eq 'contribution_required'
              end
            end

            context 'capital not_eligible' do
              let(:capital_result) {'not_eligible'}
              it 'should set the assessment to not_eligible' do
                subject
                expect(assessment.assessment_result).to eq 'not_eligible'
              end
            end
          end

          context 'disposable income has a result' do
            let(:disposable_income_result) {'eligible'}
            let(:capital_result) {'eligible'}
            it 'should raise' do
              expect{subject}.to raise_error RuntimeError, 'Invalid assessment status: for passported applicant'
            end
          end
        end
      end
    end
  end
end
