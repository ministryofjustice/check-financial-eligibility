FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| format('CLIENT-REF-%04d', n) }
    sequence(:remote_ip) { |n| "192.168.0.#{n}" }
    submission_date { Date.today }
    matter_proceeding_type { 'domestic_abuse' }
  end
end
