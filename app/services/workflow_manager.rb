class WorkflowManager

  def initialize(particulars, workflow)
    @particulars = particulars
    @workflow = workflow
    @workflow_terminated = false
  end

  def call
    start_step = @workflow[:start_step]
    process_step(step_config: start_step, step_name: :start_step)
  end

  private

  def process_step(step_config:, step_name:)
    @workflow_terminated = true if step_config == :end_workflow
    return if @workflow_terminated
    if step_config.key?(:klass)
      process_service(step_config: step_config, step_name: step_name)
    else
      raise ArgumentError, "Step #{step_name.inspect} has no :klass key"
    end
  end

  def process_service(step_config:, step_name:)
    service_class = step_config[:klass]
    result = service_class.new(@particulars).result_for
    next_step = step_config[("#{result}_step").to_sym]
    process_step(step_config: @workflow[next_step], step_name: next_step)
  end
end
