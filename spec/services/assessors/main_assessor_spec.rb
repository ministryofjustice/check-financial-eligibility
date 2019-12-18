require 'rails_helper'

module Assessors
  RSpec.describe MainAssessor do
    describe '.call' do
      let(:capital_summary) { create :capital_summary, capital_assessment_result: result }
      let(:assessment) { capital_summary.assessment }

      subject { described_class.call(assessment) }
      context 'passported applicants' do
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
