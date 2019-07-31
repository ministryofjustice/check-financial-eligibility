FactoryBot.define do
  factory :assessment do
    sequence(:client_reference_id) { |n| format('CLIENT-REF-%04d', n) }
    remote_ip { Faker::Internet.ip_v4_address }
    submission_date { Date.today }
    matter_proceeding_type { 'domestic_abuse' }
  end
end
