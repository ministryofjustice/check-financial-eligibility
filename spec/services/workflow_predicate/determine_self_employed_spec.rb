require 'rails_helper'

module WorkflowPredicate
  RSpec.describe DetermineSelfEmployed do
    let(:particulars) { double AssessmentParticulars }
    let(:service) { described_class.new(particulars) }

    it 'returns false' do
      # dummy this out until DetermineSelfEmployed acually has code
      request_hash = {
        meta_data: {
          submission_date: Date.today
        }
      }
      request = JSON.parse(request_hash.to_json, object_class: OpenStruct)
      allow(particulars).to receive(:request).and_return(request)
      expect(service.call).to be false
    end
  end
end
