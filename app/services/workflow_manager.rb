class WorkflowManager
  def initialize(assessment_id, workflow)
    @assessment = Assessment.find assessment_id
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

    step_config.key?(:klass) ? process_service(step_config: step_config) : raise(ArgumentError, "Step #{step_name.inspect} has no :klass key")
  end

  def process_service(step_config:)
    service_class = step_config[:klass]
    result = service_class.new(@assessment).call
    next_step = step_config["#{result}_step".to_sym]
    process_step(step_config: @workflow[next_step], step_name: next_step)
  end
end
