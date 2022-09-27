FactoryBot.define do
  factory :assessment_error do
    assessment
    record_id { SecureRandom.uuid }
    record_type { Faker::Lorem.word }
    error_message { Faker::Lorem.sentence }
  end
end
