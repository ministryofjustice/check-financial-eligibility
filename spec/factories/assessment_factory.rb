FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| format('CLIENT-REF-%04d', n) }
    sequence(:remote_ip) { |n| "192.168.0.#{n}" }
    request_payload { AssessmentFixture.json }
  end
end
