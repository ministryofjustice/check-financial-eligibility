require 'rails_helper'
require Rails.root.join 'spec/fixtures/test_workflow.rb'

RSpec.describe WorkflowManager do
  let(:assessment) { create :assessment }
  let(:manager) { described_class.new(assessment.id, workflow) }
  let(:particulars) { double 'particulars' }
  let(:workflow) { TestWorkflow.workflow }

  it 'follows non-passported, self-employed flow' do
    expect_service_result(WorkflowPredicate::DeterminePassported, false)
    expect_service_result(WorkflowPredicate::DetermineSelfEmployed, true)
    expect_service_result(WorkflowService::SelfEmployed, true)
    expect(WorkflowService::Passported).not_to receive(:new)
    manager.call
  end

  it 'follows the passported flow' do
    expect_service_result(WorkflowPredicate::DeterminePassported, true)
    expect_service_result(WorkflowService::Passported, true)
    expect(WorkflowPredicate::DetermineSelfEmployed).not_to receive(:new)
    expect(WorkflowService::SelfEmployed).not_to receive(:new)
    manager.call
  end

  def expect_service_result(klass, result)
    expect(klass).to receive(:new).with(assessment).and_return(double(klass, call: result))
  end
end
