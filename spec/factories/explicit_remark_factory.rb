FactoryBot.define do
  factory :explicit_remark do
    assessment
    category { "policy_disregards" }
    remark { Faker::Lorem.sentence(word_count: (3..6).to_a.sample) }
  end
end
