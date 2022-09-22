FactoryBot.define do
  factory :request_log do
    assessment_id { SecureRandom.uuid }
    request_method { "GET" }
    endpoint { "/assessments/a2986837-ae8f-4b5b-8d56-1459230aa449" }
    params { "blah blah" }
    http_status { 200 }
    response { "responding blah" }
    duration { 0.235087185 }
  end
end
