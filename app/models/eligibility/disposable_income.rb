module Eligibility
  class DisposableIncome < Base
    validates :upper_threshold, :lower_threshold, presence: true

    belongs_to :disposable_income_summary, inverse_of: :eligibilities, foreign_key: :parent_id
  end
end
