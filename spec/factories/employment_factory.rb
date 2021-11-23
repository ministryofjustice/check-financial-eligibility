FactoryBot.define do
  factory :employment do
    assessment
    sequence(:name) { |n| "Job #{n}" }
  end
end
