FactoryBot.define do
  factory :result do
    assessment

    transient do
      disposable_monthly_income { nil }
    end

    after(:create) do |result, evaluator|
      if evaluator.disposable_monthly_income.present?
        result.details['income'] = {} if result.details['income'].nil?
        result.details['income']['monthly_disposable_income'] = evaluator.disposable_monthly_income
      end
      result.save!
    end
  end
end
