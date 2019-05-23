require 'rails_helper'

RSpec.describe WorkflowManager do

  it 'does' do
    manager = WorkflowManager.new(RecursiveOpenStruct.new)
    manager.call
    expect(manager).to be_instance_of(WorkflowManager)
  end

end
