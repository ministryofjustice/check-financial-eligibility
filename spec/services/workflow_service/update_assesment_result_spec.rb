require 'rails_helper'

module WorkflowService
  RSpec.describe UpdateAssessmentResult do
    let(:assessment) { capital_summary.assessment }

    before { UpdateAssessmentResult.new(assessment).call }

    context 'pending' do
      let(:capital_summary) { create :capital_summary, :pending }
      it 'leaves the assessment result as pending' do
        expect(assessment.assessment_result).to eq 'pending'
      end
    end

    context 'eligible' do
      let(:capital_summary) { create :capital_summary, :eligible }
      it 'changes the assessment result to eligible' do
        expect(assessment.assessment_result).to eq 'eligible'
      end
    end

    context 'not_eligible' do
      let(:capital_summary) { create :capital_summary, :not_eligible }
      it 'changes the assessment result to not_eligible' do
        expect(assessment.assessment_result).to eq 'not_eligible'
      end
    end

    context 'contribution_required' do
      let(:capital_summary) { create :capital_summary, :contribution_required }
      it 'changes the assessment result to capital_contribution_required' do
        expect(assessment.assessment_result).to eq 'capital_contribution_required'
      end
    end
  end
end
