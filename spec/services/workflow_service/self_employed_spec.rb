require 'rails_helper'

module WorkflowService
  RSpec.xdescribe SelfEmployed do
    let(:particulars) { double AssessmentParticulars }
    let(:service) { described_class.new(particulars) }

    it 'returns true' do
      # dummy this out until SelfEmployed acually has code
      request_hash = {
        meta_data: {
          submission_date: Date.today
        }
      }
      request = JSON.parse(request_hash.to_json, object_class: DatedStruct)
      allow(particulars).to receive(:request).and_return(request)
      expect(service.call).to be true
    end
  end
end
