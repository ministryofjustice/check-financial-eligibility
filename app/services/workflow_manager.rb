class WorkflowManager

  def initialize(particulars)
    @particulars = particulars
    @workflow = StandardWorkflow.workflow
    @workflow_terminated = false
  end

  def call
    start_step = @workflow[:start_step]
    process_step(step_config: start_step, step_name: :start_step)
  end

  private

  def process_step(step_config:, step_name:)
    @workflow_terminated = false if step_name == :end
    return if @workflow_terminated
    if step_config.key?(:predicate)
      process_predicate(step_config: step_config, step_name: step_name)
    elsif step_config.key?(:service)
      process_service(step_config: step_config, step_name: step_name)
    else
      raise ArgumentError, "Step #{step_name.inspect} has no :predicate or :service keys"
    end
  end

  def process_predicate(step_config:, _step_name:)
    predicate_class = "WorkflowPredicate::#{step_config[:predicate][:name]}".constantize
    result = predicate_class.__send__(:result?, @particulars)
    next_step = @workflow[result.to_s_to_sym]
    process_step(step_config: @workflow[next_step], step_name: next_step)
  end

  def process_service(step_config:, step_name:)
    service_class = "WorkflowService::#{step_config[:service]}".constantize
    service_class.new(@particulars).call
    next_step = step_config[:next]
    process_step(@workflow[next_step], step_name: next_step)
  end
end
