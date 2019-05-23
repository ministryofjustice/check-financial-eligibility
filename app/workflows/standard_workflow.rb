WORKFLOW = {
  start_step: {
    predicate: {
      name: 'DeterminePassported', # calls the WorkflowPredicate::DeterminePassported
      result: {
        true: :passported_step, # go to passported_step
        false: :non_passported_step # go to non_passported_step
      }
    }
  },
  passported_step: {
    service: 'Passported',  # calls the WorkflowService::Passported
    next: :end_step # go to end_step
  },
  non_passported_step: {
    predicate: {
      name: 'DetermineSelfEmployed', # calls the WorkflowPredicate::DetermineSelfEmployed
      result: {
        true: :self_employed_step, # go to self_employed_step
        false: :not_self_employed_step # go to not self employed step
      }
    }
  },
  self_employed_step: {
    service: 'SelfEmployed', # calls the WorkflowService::SelfEmployed
    next: :end_step # go to end step
  },
  not_self_employed_service: {
    service: 'NotSelfEmployed', # calls the WorflowService::NotSelfEmployed
    next: :end_step
  },
  end_step: :end_workflow
}


class StandardWorkflow
  def self.workflow
    WORKFLOW
  end
end
