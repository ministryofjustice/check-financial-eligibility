WORKFLOW = {
  start_step: {
    klass: WorkflowPredicate::DeterminePassported,
    true_step: :passported_step,
    false_step: :non_passported_step
  },
  passported_step: {
    klass: WorkflowService::Passported,
    true_step: :end_step
  },
  non_passported_step: {
    klass: WorkflowPredicate::DetermineSelfEmployed,
    true_step: :self_employed_step,
    false_step: :not_self_employed_step
  },
  self_employed_step: {
    klass: WorkflowService::SelfEmployed,
    true_step: :end_step
  },
  not_self_employed_service: {
    klass: WorkflowService::NotSelfEmployed,
    true_step: :end_step
  },
  end_step: :end_workflow
}.freeze

class TestWorkflow
  def self.workflow
    WORKFLOW
  end
end
