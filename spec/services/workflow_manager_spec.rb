require 'rails_helper'

RSpec.describe WorkflowManager do
  let(:assessment) { create :assessment }
  let(:manager) { described_class.new(assessment.id, workflow) }
  let(:particulars) { double 'particulars' }
  let(:workflow) { StandardWorkflow.workflow }

  context 'non-passported self employed' do
    it 'raises' do
      expect_service_result(WorkflowPredicate::DeterminePassported, false)
      expect_service_result(WorkflowPredicate::DetermineSelfEmployed, true)
      expect(WorkflowService::SelfEmployed).to receive(:new).and_call_original
      expect {
        manager.call
      }.to raise_error 'Not Implemented: Check Financial Eligibility has not yet been implemented for self-employed applicants'
    end
  end

  context 'non-passported, not self employed' do
    it 'raises' do
      expect_service_result(WorkflowPredicate::DeterminePassported, false)
      expect_service_result(WorkflowPredicate::DetermineSelfEmployed, false)
      expect{
        manager.call
      }.to raise_error 'Not Implemented: Check Financial Benefit has not yet been implemented for non-passported applicants'
    end
  end

  context 'passported' do
    it 'follows the passported flow' do
      expect_service_result(WorkflowPredicate::DeterminePassported, true)
      expect_service_result(WorkflowService::DisposableCapitalAssessment, true)
      expect_service_result(WorkflowService::UpdateAssessmentResult, true)
      manager.call
    end
  end

  def expect_service_result(klass, result)
    expect(klass).to receive(:new).with(assessment).and_return(double(klass, call: result))
  end
end
