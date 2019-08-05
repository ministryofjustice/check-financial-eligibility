WORKFLOW = {
  start_step: {
    klass: WorkflowPredicate::DeterminePassported,
    true_step: :passported_step,
    false_step: :non_passported_step
  },
  passported_step: {
    klass: WorkflowService::Passported,
    true_step: :calculate_disposable_capital_step
  },
  calculate_disposable_capital_step: {
    klass: WorkflowService::DisposableCapitalAssessment,
    true_step: :compare_lower_capital_threshold_step
  },
  compare_lower_capital_threshold_step: {
    klass: WorkflowPredicate::BelowLowerCapitalThresholdPredicate,
    true_step: :end_step,
    false_step: :end_step
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

class StandardWorkflow
  def self.workflow
    WORKFLOW
  end
end
