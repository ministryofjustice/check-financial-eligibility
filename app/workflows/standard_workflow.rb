WORKFLOW = {
  start_step: {
    klass: WorkflowPredicate::DeterminePassported,
    true_step: :calculate_disposable_capital_step,
    false_step: :non_passported_step
  },
  calculate_disposable_capital_step: {
    klass: WorkflowService::DisposableCapitalAssessment,
    true_step: :update_assessment_result_step,
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
  not_self_employed_step: {
    klass: WorkflowService::NotSelfEmployed,
    true_step: :end_step
  },
  update_assessment_result_step: {
    klass: WorkflowService::UpdateAssessmentResult,
    true_step: :end_step
  },
  end_step: :end_workflow
}.freeze

class StandardWorkflow
  def self.workflow
    WORKFLOW
  end
end
